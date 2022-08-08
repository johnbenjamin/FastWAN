//
//  File.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/24.
//

import Foundation
import SwiftUI

struct ThreadProperty: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var descpt: String
    var Unit: String?
    var imageName: String
    var icon: Image {
        Image(imageName)
    }
    
}

struct ThreadModel: Codable, Equatable {
    var code: Int
    var info: [ThreadInfoModel]
    var msg: String

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case info = "info"
        case msg = "msg"
    }

    init(code: Int, info: [ThreadInfoModel], msg: String, page_info: PageInfo) {
        self.code = code
        self.info = info
        self.msg = msg
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(Int.self, forKey: .code)
        info = try values.decode([ThreadInfoModel].self, forKey: .info)
        msg = try values.decode(String.self, forKey: .msg)
    }
}

struct ThreadInfoModel: Codable, Hashable {
    var address: String
    var up_id: Int
    var node_ip_type: String
    var port: String
    var tag: String
    var type: String
    var isSet: Bool = false
}
