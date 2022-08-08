//
//  NetworkEnvironment.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/25.
//

import Foundation

enum NetworkMethod: String {
    case get
    case post
    case put
    case patch
    case delete
}

protocol NetworkRoute {
    var path: String { get }
    var method: NetworkMethod { get }
    var body: [String: String]? { get }
}

extension NetworkRoute {
    var headers: [String : String]? {
        return [Environment.ConfigKey.authKey: UserManager.shared.token]
    }

    var request: URLRequest {
        var request = URLRequest(url: URL(string: Environment.apiURL.absoluteString + path)!)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()
        if method != .get {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body ?? [:])
        }

        return request
    }
}
