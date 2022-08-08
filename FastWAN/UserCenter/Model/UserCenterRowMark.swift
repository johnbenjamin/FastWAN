//
//  UserCenterRowMark.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/17.
//

import Foundation
import SwiftUI

struct UserCenterRowMark: Hashable, Codable, Identifiable {
    var id = UUID()
    var title: String
    var state: String?

    var imageName: String
    var image: Image {
        Image(imageName)
    }

}

