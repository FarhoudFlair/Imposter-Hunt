//
//  GamePhase.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import Foundation

/// Represents the current phase of the game for navigation
enum GamePhase: Equatable {
    case home
    case playerSetup
    case gameSettings
    case roleReveal
    case playing
    case endGame
}
