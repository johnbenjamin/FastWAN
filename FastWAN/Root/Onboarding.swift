//
//  Onboarding.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation

enum ToastType: Identifiable {
    case loading
    case msg

    var id: Int {
      hashValue
    }
}
