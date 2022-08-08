//
//  ProductModel.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/31.
//

import Foundation

struct ProductModel: Codable, Equatable {
    var code: Int
    var info: [ProductInfo]?
    var msg: String
//    var page_info: PageInfo?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case info = "info"
        case msg = "msg"
//        case page_info = "page_info"
    }

    init(code: Int, info: [ProductInfo], msg: String, page_info: PageInfo) {
        self.code = code
        self.info = info
        self.msg = msg
//        self.page_info = page_info
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(Int.self, forKey: .code)
        info = try values.decode([ProductInfo].self, forKey: .info)
        msg = try values.decode(String.self, forKey: .msg)
//        page_info = try values.decode(PageInfo.self, forKey: .page_info)
    }
}

struct ProductInfo: Codable, Hashable {    
    var create_time: String?
    var equip_max: Int?
    var flow_size: Int?
    var level: Int = 0
    var node_id: Int?
    var price: Float = 0
    var product_id: Int?
    var product_name: String?
    var remarks: String?
    var speed_max: Float?
    var state: Int?
    var type_id: Int?
    var update_time: String?
}

struct PageInfo: Codable, Hashable {
    var limit: Int?
    var page: Int?
    var pages: Int?
    var total: Int?
}
