// Color+Extension.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI

extension Color {

    // MARK: - Brand Colors

    /// Primary brand color. Override via Assets.xcassets for light/dark variants.
    static let brandPrimary = Color("BrandPrimary", bundle: .main)

    /// Secondary brand color.
    static let brandSecondary = Color("BrandSecondary", bundle: .main)

    // MARK: - Semantic Colors

    static let success = Color.green
    static let warning = Color.orange
    static let danger  = Color.red

    // MARK: - Hex Initializer

    /// Creates a `Color` from a hex string.
    ///
    /// Supports:
    /// - `"#RRGGBB"`
    /// - `"RRGGBB"`
    /// - `"#RRGGBBAA"`
    ///
    /// - Parameter hex: The hex color string.
    init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch sanitized.count {
        case 6:
            r = Double((rgb >> 16) & 0xFF) / 255
            g = Double((rgb >>  8) & 0xFF) / 255
            b = Double( rgb        & 0xFF) / 255
            a = 1.0
        case 8:
            r = Double((rgb >> 24) & 0xFF) / 255
            g = Double((rgb >> 16) & 0xFF) / 255
            b = Double((rgb >>  8) & 0xFF) / 255
            a = Double( rgb        & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
