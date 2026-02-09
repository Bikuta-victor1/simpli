//
//  AppTheme.swift
//  simpli
//
//  Arraxistant-inspired dark theme with orange accent
//

import SwiftUI

// MARK: - Theme Definition
// Central struct holding all design tokens. Single source of truth for colors.
struct AppTheme {
    let background: Color      // Main screen background (near-black)
    let surface: Color         // Cards, text input, elevated surfaces
    let primary: Color         // Orange accent - buttons, selected states, CTAs
    let textPrimary: Color     // Main titles and body text (white)
    let textSecondary: Color   // Descriptions, hints, sublabels (grey)
    let inactive: Color        // Unselected tabs, disabled states
    let error: Color           // Validation errors, warnings
    let success: Color         // Checkmarks, positive feedback

    static let dark = AppTheme(
        background: Color(hex: "0D0D0F"),
        surface: Color(hex: "1C1C1E"),
        primary: Color(hex: "FF6F00"),
        textPrimary: Color.white,
        textSecondary: Color(hex: "8E8E93"),
        inactive: Color(hex: "3A3A3C"),
        error: Color(hex: "FF3B30"),
        success: Color(hex: "34C759")
    )
}

// MARK: - Color Hex Extension
// Lets us use hex strings like "FF6F00" instead of Color(red:green:blue:)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

// MARK: - Environment Key
// Makes the theme available to any view via @Environment(\.appTheme)
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .dark
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    /// Injects the theme into the view hierarchy. Call once at app root.
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
