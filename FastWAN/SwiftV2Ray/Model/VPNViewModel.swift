//
//  HomeContentViewModel.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/5.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import Alamofire
import Combine
import NetworkExtension

enum ProxyMode: Int {
    case auto = 0
    case global = 1
    case direct = 2
}

@available(iOS 13.0, *)
class VPNViewModel: ObservableObject, Codable {
    @Published var serviceOpen: Bool = false
    @Published var subscribeUrl: URL? = nil
    @Published var serviceEndPoints: [VmessEndpoint] = []
    @Published var proxyMode: ProxyMode = .auto
    var v2rayConfig: V2RayConfig = V2RayConfig.parse(fromJsonFile: "default_config")!
    private var serviceOpenEventSink: AnyCancellable? = nil
    private var activingEndpointEventSink: AnyCancellable? = nil
    private var threadInfoModel: ThreadInfoModel? = nil {
        didSet {
            guard let threadInfoModel = threadInfoModel else { return }
            updateConfig(threadInfoModel)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case subscribeUrl
        case activingEndpoint
        case serviceEndPoints
        case proxyMode
    }
    
    init() {
        loadServices()
        updateConfig()
        
        // 打开服务事件处理
        self.serviceOpenEventSink = $serviceOpen.sink {[weak self] (toOpen) in
            if toOpen == false {
                self?.closeService(nil)
                return
            }
            self?.openService { (error) in
                guard error != nil else { return }
                DispatchQueue.main.async {
                    self?.serviceOpen = false
                }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        subscribeUrl != nil ? try container.encode(subscribeUrl?.absoluteString, forKey: .subscribeUrl) : nil
        try container.encode(proxyMode.rawValue, forKey: .proxyMode)
        try container.encode(serviceEndPoints, forKey: .serviceEndPoints)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let string = values.contains(.subscribeUrl) ? try values.decode(String.self, forKey: .subscribeUrl) : nil
        subscribeUrl = string != nil ? URL.init(string: string!) : nil
        proxyMode = ProxyMode(rawValue: try values.decode(Int.self, forKey: .proxyMode)) ?? .auto
        serviceEndPoints = try values.decode([VmessEndpoint].self, forKey: .serviceEndPoints)
    }
    
    func requestServices(withUrl requestUrl: URL?, completion: ((_ error: Error?)-> Void)?) {
        guard let url = requestUrl else {
            return
        }
        
        AirportTool.getSubscribeVmessPoints(url) {[weak self] (serverPoints, error) in
            guard error == nil else {
                if completion != nil {
                    completion!(error)
                }
                return
            }
            
            self?.serviceEndPoints = serverPoints!
            
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    func storeServices() {
        guard let data = try? PropertyListEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "VmessService")
        UserDefaults.standard.synchronize()
    }
    
    func loadServices() {
        guard let data = UserDefaults.standard.data(forKey: "VmessService") else { return }
        let viewModel = try? PropertyListDecoder().decode(VPNViewModel.self, from: data)
        self.serviceEndPoints = viewModel?.serviceEndPoints ?? []
        self.proxyMode = viewModel?.proxyMode ?? .auto
        self.subscribeUrl = viewModel?.subscribeUrl
    }
    
    func openService(threadInfoModel: ThreadInfoModel? = nil, completion: ((_ error: Error?)-> Void)?) {
        self.threadInfoModel = threadInfoModel
        
        let configData = try? JSONEncoder().encode(self.v2rayConfig)
        guard configData != nil else {
            completion?(NSError(domain: "ErrorDomain", code: -1, userInfo: ["error" : "配置错误"]))
            return
        }
        guard let address = v2rayConfig.outbounds?[0].settingVMess?.vnext[0].address else { return }
        let serverIP = PacketTunnelMessage.getIPAddress(domainName: address)
        let packetTunnelMessage = PacketTunnelMessage(configData: configData, serverIP: serverIP)
        VPNHelper.shared.open(with: packetTunnelMessage, completion: { (error) in
            completion?(error)
        })
    }
    
    func closeService(_ completion: (() -> Void)?) {
        VPNHelper.shared.close { completion?() }
    }
    
    func updateConfig(_ threadInfoModel: ThreadInfoModel? = nil) {
        guard let threadInfoModel = threadInfoModel else { return }
        var vnext = Outbound.VMess.Item()
        vnext.address = threadInfoModel.address ?? ""
        vnext.port = Int(threadInfoModel.port ?? "") ?? 0
        self.v2rayConfig.outbounds?[0].settingVMess?.vnext = [vnext]
    }
}
