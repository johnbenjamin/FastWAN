//
//  File.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/7.
//

import Foundation

struct UserAuthModel: Codable {
    var code: Int
    var info: UserAuth?
    var msg: String
}

struct UserAuth: Codable, Hashable {
    var approved: Int?
    var approve_id: Int?
    var approved_time: String?
    var card_backend: String?
    var card_front: String?
    var id_card_no: String?
    var real_name: String?
    var result_resp: String?
    var sign_photo: String?
}
