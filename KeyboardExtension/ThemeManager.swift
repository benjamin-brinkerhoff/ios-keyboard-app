//
//  ThemeManager.swift
//  KeyboardExtension
//
//  Gboard-style Theme Engine with Material You dynamics and Key Border controls.
//

import SwiftUI

enum GboardTheme: String, CaseIterable, Identifiable {
    case system = "System Auto"
    case materialDark = "Dark (AMOLED)"
    case materialLight = "Light"
    case materialYou = "Dynamic Teal"
    case desertSand = "Desert Sand"
    case forestMint = "Forest Mint"
    case midnightLilac = "Midnight Lilac"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .system:
            return Color(UIColor.systemGray4)
        case .materialDark:
            return Color(red: 0.11, green: 0.11, blue: 0.12)
        case .materialLight:
            return Color(red: 0.94, green: 0.94, blue: 0.96)
        case .materialYou:
            return Color(red: 0.12, green: 0.18, blue: 0.22)
        case .desertSand:
            return Color(red: 0.92, green: 0.88, blue: 0.82)
        case .forestMint:
            return Color(red: 0.12, green: 0.20, blue: 0.17)
        case .midnightLilac:
            return Color(red: 0.16, green: 0.14, blue: 0.24)
        }
    }

    var keyStandardColor: Color {
        switch self {
        case .system:
            return Color(UIColor.systemBackground)
        case .materialDark:
            return Color(red: 0.22, green: 0.22, blue: 0.24)
        case .materialLight:
            return Color.white
        case .materialYou:
            return Color(red: 0.20, green: 0.29, blue: 0.35)
        case .desertSand:
            return Color(red: 0.98, green: 0.96, blue: 0.92)
        case .forestMint:
            return Color(red: 0.20, green: 0.31, blue: 0.27)
        case .midnightLilac:
            return Color(red: 0.26, green: 0.23, blue: 0.38)
        }
    }

    var keyModifierColor: Color {
        switch self {
        case .system:
            return Color(UIColor.systemGray5)
        case .materialDark:
            return Color(red: 0.16, green: 0.16, blue: 0.18)
        case .materialLight:
            return Color(red: 0.86, green: 0.86, blue: 0.88)
        case .materialYou:
            return Color(red: 0.16, green: 0.23, blue: 0.28)
        case .desertSand:
            return Color(red: 0.84, green: 0.79, blue: 0.72)
        case .forestMint:
            return Color(red: 0.16, green: 0.25, blue: 0.22)
        case .midnightLilac:
            return Color(red: 0.20, green: 0.18, blue: 0.30)
        }
    }

    var keyTextColor: Color {
        switch self {
        case .system:
            return .primary
        case .materialLight, .desertSand:
            return .black
        case .materialDark, .materialYou, .forestMint, .midnightLilac:
            return .white
        }
    }

    var accentColor: Color {
        switch self {
        case .system:
            return Color.accentColor
        case .materialDark:
            return Color(red: 0.54, green: 0.71, blue: 0.98)
        case .materialLight:
            return Color(red: 0.10, green: 0.45, blue: 0.91)
        case .materialYou:
            return Color(red: 0.49, green: 0.82, blue: 0.79)
        case .desertSand:
            return Color(red: 0.82, green: 0.53, blue: 0.24)
        case .forestMint:
            return Color(red: 0.51, green: 0.84, blue: 0.62)
        case .midnightLilac:
            return Color(red: 0.75, green: 0.62, blue: 0.95)
        }
    }
}

class ThemeSettings: ObservableObject {
    @Published var activeTheme: GboardTheme = .system
    @Published var showKeyBorders: Bool = true
}
