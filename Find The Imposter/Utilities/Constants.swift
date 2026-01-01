//
//  Constants.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// App-wide constants
enum Constants {
    // MARK: - Player Limits
    static let minPlayers = 3
    static let maxPlayers = 12
    static let defaultPlayerCount = 3

    // MARK: - Animation Durations
    static let quickAnimation: Double = 0.2
    static let standardAnimation: Double = 0.3
    static let slowAnimation: Double = 0.5
    static let cardFlipDuration: Double = 0.6

    // MARK: - Layout
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 12
    static let standardPadding: CGFloat = 16
    static let largePadding: CGFloat = 24

    // MARK: - Card Dimensions
    static let cardAspectRatio: CGFloat = 0.65  // width/height
    static let cardMaxWidth: CGFloat = 320
    static let cardMaxHeight: CGFloat = 480
    static let flipThreshold: CGFloat = 60

    // MARK: - Fonts
    static let titleFont: Font = .largeTitle.bold()
    static let headlineFont: Font = .title2.bold()
    static let bodyFont: Font = .body
    static let captionFont: Font = .caption

    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [.purple, .blue, .indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let imposterGradient = LinearGradient(
        colors: [.red, .orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let safeGradient = LinearGradient(
        colors: [.green, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.1, blue: 0.2),
            Color(red: 0.15, green: 0.1, blue: 0.25),
            Color(red: 0.1, green: 0.15, blue: 0.3)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
