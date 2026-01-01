//
//  Color+Theme.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let imposterRed = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let safeGreen = Color(red: 0.2, green: 0.8, blue: 0.4)

    // MARK: - Background Colors
    static let darkBackground = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.18)
    static let elevatedBackground = Color(red: 0.15, green: 0.15, blue: 0.22)

    // MARK: - Accent Colors
    static let primaryAccent = Color.purple
    static let secondaryAccent = Color.blue
    static let warningAccent = Color.orange
    static let hintAccent = Color.yellow

    // MARK: - Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.5)

    // MARK: - Category Colors (for visual variety)
    static let categoryColors: [Color] = [
        .purple, .blue, .indigo, .cyan, .teal,
        .green, .mint, .yellow, .orange, .pink
    ]

    /// Get a consistent color for a category based on its ID
    static func forCategory(_ categoryId: String) -> Color {
        let hash = abs(categoryId.hashValue)
        return categoryColors[hash % categoryColors.count]
    }
}
