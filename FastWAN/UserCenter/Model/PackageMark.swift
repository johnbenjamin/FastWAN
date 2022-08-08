//
//  PackageMaker.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/20.
//

import SwiftUI
import Foundation

struct PackageMark: Hashable, Codable, Identifiable {
    var id: Int
    
    var packageSize: String
    var descption: String
    var price: String
    var discountTitle: String?
    var isDiscount: Bool
}
