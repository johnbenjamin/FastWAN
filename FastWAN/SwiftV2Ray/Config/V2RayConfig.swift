//
//  V2RayConfig.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/11/30.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation

// 参考[V2rayU实现修改](https://github.com/yanue/V2rayU)
// doc: https://www.V2Ray.com/chapter_02/01_overview.html
struct V2RayConfig: Codable {
    var log: Log?
    var api: Api?
    var dns: Dns?
    var stats: Stats?
    var routing: Routing?
    var policy: Policy?
    var inbounds: [Inbound]?
    var outbounds: [Outbound]?
    var transport: Transport?
}

extension Decodable {
    static func parse(fromJsonFile: String) -> Self? {
        guard let url = Bundle.main.url(forResource: fromJsonFile, withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return nil
        }
        var output: Self?
        do {
            output = try JSONDecoder().decode(self, from: data)
        } catch(let e) {
            print("User creation failed with error: \(e)")
        }
        return output
    }
    
    static func convert(threadInfoModel: ThreadInfoModel, fromJsonFile: String) -> Self? {
        
        guard let url = Bundle.main.url(forResource: fromJsonFile, withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        var dic: [String: Any]?
        do {
            dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
        
        guard var dic = dic else { return nil }
        guard let outbounds = dic["outbounds"] as? [[String : Any]] else { return nil }
        guard var outbound = outbounds.first else { return nil }
        guard var settings = outbound["settings"] as? [String: Any] else { return nil }
        guard var vnexts = settings["vnext"] as? [[String: Any]] else { return nil }
        guard var vnext = vnexts.first else { return nil }
        vnext["address"] = threadInfoModel.address ?? ""
        vnext["port"] = Int(threadInfoModel.port ?? "") ?? 0
        vnexts = [vnext]
        settings["vnext"] = vnexts
        outbound["settings"] = settings
        dic["outbounds"] = [outbound]
        
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted) else { return nil }
        var output: Self?
        do {
            output = try JSONDecoder().decode(self, from: data)
        } catch(let e) {
            print("User creation failed with error: \(e)")
        }
        return output
    }
}

// MARK: - Log
struct Log: Codable {
    var loglevel: Level = .info
    var error: String? = ""
    var access: String? = ""
    
    enum Level: String, Codable {
        case debug
        case info
        case warning
        case error
        case none
    }
}

// MARK: - API
struct Api: Codable {

}

// MARK: - DNS
struct Dns: Codable {
    var hosts: [String:String] = [:]
    var servers: [String] = ["1.1.1.1", "8.8.8.8", "8.8.4.4", "119.29.29.29", "114.114.114.114", "223.5.5.5", "223.6.6.6"]
}

// MARK: - Stats
struct Stats: Codable {

}

// MARK: - Routing
struct Routing: Codable {
    var domainStrategy: domainStrategy = .IPIfNonMatch
    var rules: [Rule] = [Rule()]

    enum domainStrategy: String, Codable {
        case AsIs
        case IPIfNonMatch
        case IPOnDemand
    }

    struct Rule: Codable {
        var type: String? = "field"
        var domain: [String]? = ["geosite:cn", "geosite:speedtest"]
        var ip: [String]? = ["geoip:cn", "geoip:private"]
        var port: String?
        var network: String?
        var source: [String]?
        var user: [String]?
        var inboundTag: [String]?
        var `protocol`: [String]? // ["http", "tls", "bittorrent"]
        var outboundTag: String? = "direct"
    }
}

// MARK: - Policy
struct Policy: Codable {
    
}

// MARK: - Inbound
struct Inbound: Codable {
    var port: Int = 1080
    var listen: String = "127.0.0.1"
    var `protocol`: Protocol = .socks
    var tag: String? = nil
    var streamSettings: StreamSettings? = nil
    var sniffing: Sniffing? = nil
    var allocate: Allocate? = nil

    var settingHttp: Http = Http()
    var settingSocks: Socks = Socks()
    var settingShadowsocks: Shadowsocks? = nil
    var settingVMess: VMess? = nil

    enum CodingKeys: String, CodingKey {
        case port
        case listen
        case `protocol`
        case tag
        case streamSettings
        case sniffing
        case settings
    }
    
    enum `Protocol`: String, Codable {
        case http
        case shadowsocks
        case socks
        case vmess
    }
    
    struct Allocate: Codable {
        var strategy: strategy = .always    // always or random
        var refresh: Int = 2                // val is 2-5 where strategy = random
        var concurrency: Int = 3            // suggest 3, min 1
        
        enum strategy: String, Codable {
            case always
            case random
        }
    }

    struct Sniffing: Codable {
        var enabled: Bool = false
        var destOverride: [dest] = [.tls, .http]
        
        enum dest: String, Codable {
            case tls
            case http
        }
    }

    struct Http: Codable {
        var timeout: Int? = 360
        var allowTransparent: Bool?
        var userLevel: Int?
        var accounts: [Account]?
        
        struct Account: Codable {
            var user: String?
            var pass: String?
        }
    }

    struct Shadowsocks: Codable {
        var email, method, password: String?
        var udp: Bool = false
        var level: Int = 0
        var ota: Bool = true
        var network: String = "tcp" // "tcp" | "udp" | "tcp,udp"
    }

    struct Socks: Codable {
        var auth: String = "noauth" // noauth | password
        var accounts: [Account]?
        var udp: Bool = true
        var ip: String?
        var timeout: Int? = 360
        var userLevel: Int?
        
        struct Account: Codable {
            var user: String?
            var pass: String?
        }
    }

    struct VMess: Codable {
        var clients: [Client]?
        var `default`: Default? = Default()
        var detour:Detour?
        var disableInsecureEncryption: Bool = false
        
        struct Client: Codable {
            var id: String?
            var level: Int = 0
            var alterId: Int = 64
            var email: String?
        }

        struct Detour: Codable {
            var to: String?
        }

        struct Default: Codable {
            var level: Int = 0
            var alterId: Int = 64
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port = try container.decode(Int.self, forKey: .port)
        listen = try container.decode(String.self, forKey: .listen)
        `protocol` = try container.decode(Protocol.self, forKey: .`protocol`)
        
        tag = container.contains(.tag) ? try container.decode(String.self, forKey: .tag) : nil
        streamSettings = container.contains(.streamSettings) ? try container.decode(StreamSettings.self, forKey: CodingKeys.streamSettings) : nil
        sniffing = container.contains(.sniffing) ? try container.decode(Sniffing.self, forKey: CodingKeys.sniffing) : nil

        switch `protocol` {
        case .http:
            settingHttp = try container.decode(Http.self, forKey: CodingKeys.settings)
        case .shadowsocks:
            settingShadowsocks = try container.decode(Shadowsocks.self, forKey: CodingKeys.settings)
        case .socks:
            settingSocks = try container.decode(Socks.self, forKey: CodingKeys.settings)
        case .vmess:
            settingVMess = try container.decode(VMess.self, forKey: CodingKeys.settings)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(port, forKey: .port)
        try container.encode(listen, forKey: .listen)
        try container.encode(`protocol`, forKey: .`protocol`)

        tag == nil ? nil : try container.encode(tag, forKey: .tag)
        streamSettings == nil ? nil : try container.encode(streamSettings, forKey: .streamSettings)
        sniffing == nil ? nil : try container.encode(sniffing, forKey: .sniffing)

        switch `protocol` {
        case .http:
            try container.encode(self.settingHttp, forKey: .settings)
        case .shadowsocks:
            try container.encode(self.settingShadowsocks, forKey: .settings)
        case .socks:
            try container.encode(self.settingSocks, forKey: .settings)
        case .vmess:
            try container.encode(self.settingVMess, forKey: .settings)
        }
    }
}

// MARK: - Outbound
struct Outbound: Codable {
    var `protocol`: Protocol = .freedom
    var sendThrough: String? = nil
    var tag: String? = nil
    var streamSettings: StreamSettings? = nil
    var proxySettings: Settings? = nil
    var mux: Mux? = nil

    var settingBlackhole: Blackhole? = nil
    var settingFreedom: Freedom? = nil
    var settingShadowsocks: Shadowsocks? = nil
    var settingSocks: Socks? = nil
    var settingVMess: VMess? = nil
    var settingDns: Dns? = nil

    enum CodingKeys: String, CodingKey {
        case sendThrough
        case `protocol`
        case tag
        case streamSettings
        case proxySettings
        case mux
        case settings
    }
    
    struct Settings: Codable {
        var tag: String?
    }
    
    enum `Protocol`: String, Codable {
        case blackhole
        case freedom
        case shadowsocks
        case socks
        case vmess
        case dns
    }
    
    struct Mux: Codable {
        var enabled: Bool = false
        var concurrency: Int? = 8
    }

    struct Blackhole: Codable {
        var response: Response = Response()
        
        struct Response: Codable {
            var type: String? = "none" // none | http
        }
    }

    struct Freedom: Codable {
        var domainStrategy: String = "AsIs" // UseIP | AsIs
        var redirect: String?
        var userLevel: Int = 0
    }

    struct Shadowsocks: Codable {
        var servers: [Server] = [Server()]
        
        struct Server: Codable {
            var email: String = ""
            var address: String = ""
            var port: Int = 0
            var method: Method = .aes256cfb
            var password: String = ""
            var ota: Bool = false
            var level: Int = 0
        }

        enum Method: String, Codable {
            case aes256cfb = "aes-256-cfb"
            case aes128cfb = "aes-128-cfb"
            case chacha20 = "chacha20"
            case chacha20ietf = "chacha20-ietf"
            case aes256gcm = "aes-256-gcm"
            case aes128gcm = "aes-128-gcm"
            case chacha20poly1305 = "chacha20-poly1305"
            case chacha20ietfpoly1305 = "chacha20-ietf-poly1305"
        }
    }

    struct Socks: Codable {
        var address: String = ""
        var port: String = ""
        var users: [User] = [User()]
        
        struct User: Codable {
            var user: String = ""
            var pass: String = ""
            var level: Int = 0
        }
    }

    struct VMess: Codable {
        var vnext: [Item] = [Item()]
        
        struct Item: Codable {
            var address: String = ""
            var port: Int = 443
            var users: [User] = [User()]
            
            struct User: Codable {
                var id: String = ""
                var alterId: Int? = 0 // 0-65535
                var level: Int? = 0
                var security: Security = .auto
                var encryption: String? = ""
                var flow: String? = ""
                enum Security: String, Codable {
                    case aes128gcm = "aes-128-gcm"
                    case chacha20poly1305 = "chacha20-poly1305"
                    case auto = "auto"
                    case none = "none"
                }
            }
        }
    }

    struct Dns: Codable {
        var network: String = "" // "tcp" | "udp" | ""
        var address: String = ""
        var port: Int?
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        `protocol` = try container.decode(Protocol.self, forKey: CodingKeys.`protocol`)

        tag = container.contains(.tag) ? try container.decode(String.self, forKey: .tag) : nil
        sendThrough = container.contains(.sendThrough) ? try container.decode(String.self, forKey: CodingKeys.sendThrough) : nil
        proxySettings = container.contains(.proxySettings) ?  try container.decode(Settings.self, forKey: CodingKeys.proxySettings) : nil
        streamSettings = container.contains(.streamSettings) ? try container.decode(StreamSettings.self, forKey: CodingKeys.streamSettings) : nil
        mux = container.contains(.mux) ? try container.decode(Mux.self, forKey: CodingKeys.mux) : nil

        switch `protocol` {
        case .blackhole:
            settingBlackhole = try container.decode(Blackhole.self, forKey: CodingKeys.settings)
        case .freedom:
            settingFreedom = try container.decode(Freedom.self, forKey: CodingKeys.settings)
        case .shadowsocks:
            settingShadowsocks = try container.decode(Shadowsocks.self, forKey: CodingKeys.settings)
        case .socks:
            settingSocks = try container.decode(Socks.self, forKey: CodingKeys.settings)
        case .vmess:
            settingVMess = try container.decode(VMess.self, forKey: CodingKeys.settings)
        case .dns:
            settingDns = try container.decode(Dns.self, forKey: CodingKeys.settings)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(`protocol`, forKey: .`protocol`)
        
        tag == nil ? nil : try container.encode(tag, forKey: .tag)
        streamSettings == nil ? nil : try container.encode(streamSettings, forKey: .streamSettings)
        (sendThrough == nil || sendThrough!.count <= 0) ? nil : try container.encode(sendThrough, forKey: .sendThrough)
        proxySettings == nil ? nil : try container.encode(proxySettings, forKey: .proxySettings)
        mux == nil ? nil : try container.encode(mux, forKey: .mux)

        switch `protocol` {
        case .shadowsocks:
            try container.encode(self.settingShadowsocks, forKey: .settings)
        case .socks:
            try container.encode(self.settingSocks, forKey: .settings)
        case .vmess:
            try container.encode(self.settingVMess, forKey: .settings)
        case .blackhole:
            try container.encode(self.settingBlackhole, forKey: .settings)
        case .freedom:
            try container.encode(self.settingFreedom, forKey: .settings)
        case .dns:
            try container.encode(self.settingDns, forKey: .settings)
        }
    }
}

// MARK: - Transport
struct Transport: Codable {
    var tlsSettings: StreamSettings.TlsSettings?
    var tcpSettings: StreamSettings.TcpSettings?
    var kcpSettings: StreamSettings.KcpSettings?
    var wsSettings: StreamSettings.WsSettings?
    var httpSettings: StreamSettings.HttpSettings?
    var dsSettings: StreamSettings.DsSettings?
    var quicSettings: StreamSettings.QuicSettings?
}

// MARK: - StreamSetting
struct StreamSettings: Codable {
    var network: network = .tcp
    var security: security = .none
    var sockopt: Sockopt?
    var tlsSettings: TlsSettings?
    var tcpSettings: TcpSettings?
    var kcpSettings: KcpSettings?
    var wsSettings: WsSettings?
    var httpSettings: HttpSettings?
    var dsSettings: DsSettings?
    var quicSettings: QuicSettings?
    
    enum network: String, Codable {
        case tcp
        case kcp
        case ws
        case http
        case h2
        case domainsocket
        case quic
    }

    enum security: String, Codable {
        case none
        case tls
    }
    
    struct TlsSettings: Codable {
        var serverName: String?
        var alpn: String?
        var allowInsecure: Bool?
        var allowInsecureCiphers: Bool?
        var certificates: TlsCertificates?
        
        struct TlsCertificates: Codable {
            enum usage: String, Codable {
                case encipherment
                case verify
                case issue
            }

            var usage: usage? = .encipherment
            var certificateFile: String?
            var keyFile: String?
            var certificate: String?
            var key: String?
        }
    }

    struct TcpSettings: Codable {
        var header: Header = Header()
        
        struct Header: Codable {
            var type: String = "none"
            var request: Request?
            var response: Response?
            
            struct Request: Codable {
                var version: String = ""
                var method: String = ""
                var path: [String] = []
                var headers: Headers = Headers()
                
                struct Headers: Codable {
                    var host: [String] = []
                    var userAgent: [String] = []
                    var acceptEncoding: [String] = []
                    var connection: [String] = []
                    var pragma: String = ""

                    enum CodingKeys: String, CodingKey {
                        case host = "Host"
                        case userAgent = "User-Agent"
                        case acceptEncoding = "Accept-Encoding"
                        case connection = "Connection"
                        case pragma = "Pragma"
                    }
                }
            }
            
            struct Response: Codable {
                var version, status, reason: String?
                var headers: Headers?
                
                struct Headers: Codable {
                    var contentType, transferEncoding, connection: [String]?
                    var pragma: String?

                    enum CodingKeys: String, CodingKey {
                        case contentType = "Content-Type"
                        case transferEncoding = "Transfer-Encoding"
                        case connection = "Connection"
                        case pragma = "Pragma"
                    }
                }
            }
        }
    }

    struct KcpSettings: Codable {
        var mtu: Int = 1350
        var tti: Int = 20
        var uplinkCapacity: Int = 50
        var downlinkCapacity: Int = 20
        var congestion: Bool = false
        var readBufferSize: Int = 1
        var writeBufferSize: Int = 1
        var header: Header = Header()
        
        struct Header: Codable {
            var type: Type = .none
            
            enum `Type`: String, Codable {
                case none = "none"
                case srtp = "srtp"
                case utp = "utp"
                case wechatVideo = "wechat-video"
                case dtls = "dtls"
                case wireguard = "wireguard"
            }
        }
    }

    struct WsSettings: Codable {
        var path: String = ""
        var headers: Header = Header()
        
        struct Header: Codable {
            var host: String = ""
        }
    }

    struct HttpSettings: Codable {
        var host: [String] = [""]
        var path: String = ""
    }

    struct DsSettings: Codable {
        var path: String = ""
    }

    struct Sockopt: Codable {
        var mark: Int = 0
        var tcpFastOpen: Bool = false
        var tproxy: tproxy = .off // only for linux
        
        enum tproxy: String, Codable {
            case redirect
            case tproxy
            case off
        }
    }

    struct QuicSettings: Codable {
        var security: Security = .none
        var key: String = ""
        var header: Header = Header()
        
        struct Header: Codable {
            var type: Type = .none
            
            enum `Type`: String, Codable {
                case none = "none"
                case srtp = "srtp"
                case utp = "utp"
                case wechatVideo = "wechat-video"
                case dtls = "dtls"
                case wireguard = "wireguard"
            }
        }
        
        enum Security: String, Codable {
            case none = "none"
            case aes128gcm = "aes-128-gcm"
            case chacha20poly1305 = "chacha20-poly1305"
        }
    }
}

