//
//  Player.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import Foundation

/// Represents a player in the game with their role assignment
struct Player: Identifiable, Hashable, Equatable {
    let id: UUID
    var name: String
    var isImposter: Bool
    var hasRevealedRole: Bool

    init(id: UUID = UUID(), name: String, isImposter: Bool = false, hasRevealedRole: Bool = false) {
        self.id = id
        self.name = name
        self.isImposter = isImposter
        self.hasRevealedRole = hasRevealedRole
    }
}
