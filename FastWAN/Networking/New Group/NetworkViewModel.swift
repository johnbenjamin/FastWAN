//
//  NetworkViewModel.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/26.
//

import Foundation
import Combine

protocol NetworkViewModel: ObservableObject {
    associatedtype NetworkResource: Decodable
    
    var objectWillChange: ObservableObjectPublisher { get }
    var resource: Resource<NetworkResource> { get set }
    var network: Network { get set }
    var route: NetworkRoute { get }
    var bag: Set<AnyCancellable> { get set }
    
    func onAppear()
}

extension NetworkViewModel {
    func fetch(route: NetworkRoute) {
        (network.fetch(route: route) as AnyPublisher<NetworkResource, Error>)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.resource = .error(error)
                    self.objectWillChange.send()
                default:
                    break
                }
            } receiveValue: { decodable in
                self.resource = .success(decodable)
                self.objectWillChange.send()
            }.store(in: &bag)
    }

    func onAppear() {
        fetch(route: route)
    }
}
