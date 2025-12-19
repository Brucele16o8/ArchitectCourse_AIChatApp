//
//  Color+EXT.swift
//  AIChatCourse
//
//  Created by Tung Le on 14/10/2025.
//

import SwiftUI
import UIKit

extension Color {
    
    /// Initialize a Color from a hex string (e.g. "#FFAA00" or "#FFAA00CC")
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        
        let red, green, blue, alpha: Double
        switch length {
        case 6:
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0
            alpha = 1.0
        case 8:
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    /// Convert a Color to hex string (optionally including alpha)
    func toHex(includeAlpha: Bool = false) -> String? {
        // Convert SwiftUI Color → UIColor to extract RGBA components
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if includeAlpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(red * 255)),
                lroundf(Float(green * 255)),
                lroundf(Float(blue * 255)),
                lroundf(Float(alpha * 255))
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(red * 255)),
                lroundf(Float(green * 255)),
                lroundf(Float(blue * 255))
            )
        }
    }
}
