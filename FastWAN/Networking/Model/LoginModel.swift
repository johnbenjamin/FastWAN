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
    var avatar_back: String?
    var balance: Float?
    var email: String?
    var invite_code: String?
    var is_super: Int?
    var last_login_ip: String?
    var last_login_time: String?
    var last_try_time: String?
    var user_nick: String?
    var user_type: String?
    var user_uuid: String?
    var username: String?
}
