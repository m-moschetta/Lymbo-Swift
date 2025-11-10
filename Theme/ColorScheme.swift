//
//  ColorScheme.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

extension Color {
    // Main Colors
    static let primaryColor = Color(hex: "#000000") // Pure Black
    static let primaryHover = Color(hex: "#1f1f1f") // Dark Gray
    static let accentColor = Color(hex: "#ffffff") // Pure White
    static let backgroundColor = Color(hex: "#f9fafb") // Off-White/Light Gray
    
    // Neutrals
    static let foreground = Color(hex: "#252525") // Near Black (approximation of oklch(0.145 0 0))
    static let card = Color(hex: "#ffffff") // White
    static let muted = Color(hex: "#ececf0") // Light Gray
    static let mutedForeground = Color(hex: "#717182") // Medium Gray
    static let accentGray = Color(hex: "#e9ebef") // Very Light Gray
    
    // Functional Colors
    static let secondary = Color(hex: "#f5f5f7") // Very Light Lavender (approximation)
    static let destructive = Color(hex: "#d4183d") // Red
    static let border = Color.black.opacity(0.1) // 10% Black
    
    // Form Elements
    static let inputBackground = Color(hex: "#f3f3f5") // Light Gray
    static let switchBackground = Color(hex: "#cbced4") // Medium Gray
    
    // Chart Colors
    static let chart1 = Color(hex: "#ff8c42") // Orange (approximation)
    static let chart2 = Color(hex: "#4ecdc4") // Teal (approximation)
    static let chart3 = Color(hex: "#5b8cff") // Blue (approximation)
    static let chart4 = Color(hex: "#d4e157") // Yellow-Green (approximation)
    static let chart5 = Color(hex: "#ffd54f") // Yellow (approximation)
}

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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

