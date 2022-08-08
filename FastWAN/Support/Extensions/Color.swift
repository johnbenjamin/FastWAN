//
//  Color.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//
import SwiftUI

let mainColor = Color.init(hex: "#3D3CEE")
let c_F4F5F7 = Color.init(hex: "#F4F5F7")
let c_030364 = Color.init(hex: "#030364")
let c_7F8398 = Color.init(hex: "#7F8398")
let c_1ED9AD = Color.init(hex: "#1ED9AD")
let c_E2E9FB = Color.init(hex: "#E2E9FB")
let c_3D3CEE = Color.init(hex: "#3D3CEE")
let c_F1F2FF = Color.init(hex: "#F1F2FF")
let c_820000 = Color.init(hex: "#820000")
let c_FDCB7F = Color.init(hex: "#FDCB7F")
let c_FFBF78 = Color.init(hex: "#FFBF78")
let c_999999 = Color.init(hex: "#999999")
let c_E3E6EE = Color.init(hex: "#E3E6EE")

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
