//
//  Network.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/26.
//

import Foundation
import Combine

protocol Network {
    var decoder: JSONDecoder { get set }
    var enviroment: NetworkEnvironment { get set}
}

extension Network {
    func fetch<T: Decodable>(route: NetworkRoute) -> AnyPublisher<T, Error> {
        let request = route.create(for: enviroment)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryCompactMap { result in
                try self.decoder.decode(T.self, from: result.data)
            }.receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

struct NetworkInstance: Network {
    var decoder: JSONDecoder = JSONDecoder()
    var enviroment: NetworkEnvironment = .baseURL
}
