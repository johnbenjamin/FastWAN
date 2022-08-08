//
//  ThreadMark.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/24.
//

import SwiftUI

struct ThreadMark: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var isSet: Bool
}
