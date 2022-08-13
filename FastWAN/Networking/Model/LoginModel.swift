//
//  InfoModel.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation

struct LoginModel: Codable {
    var code: Int
    var info: LoginInfo?
    var msg: String
}

struct LoginInfo: Codable, Hashable {
    var token: String
    var userInfo: UserInfo?
}

struct UserInfo: Codable, Hashable {
    var approved: Int?
    var avatar: String?
    var avatarBack: String?
    var balance: Float?
    var email: String?
    var inviteCode: String?
    var isSuper: Int?
    var lastLoginIp: String?
    var lastLoginTime: String?
    var lastTryTime: String?
    var userNick: String?
    var userType: String?
    var userUuid: String?
    var username: String?
}




struct VersionModel: Codable {
    var code: Int
    var info: VersionInfo?
    var msg: String
}

struct VersionInfo: Codable, Hashable {
    var content: String?
    var forceUpdate: Bool = false
    var url: String?
    var versionCode: String?
    var versionName: String?
}
