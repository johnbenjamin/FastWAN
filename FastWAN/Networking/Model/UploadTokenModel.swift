//
//  UploadTokenModel.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/2.
//

import Foundation

struct UploadTokenModel: Codable {
    var code: Int
    var info: TokenInfo
    var msg: String
}

struct TokenInfo: Codable, Hashable {
    var token: String
}

struct PrivateTokenModel: Codable {
    var code: Int
    var info: PrivateTokenInfo
    var msg: String
}

struct PrivateTokenInfo: Codable, Hashable {
    var url: String
}
