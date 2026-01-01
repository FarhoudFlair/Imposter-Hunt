//
//  Difficulty.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import Foundation

/// Game difficulty levels affecting word complexity
enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case kids = "kids"
    case medium = "medium"
    case hard = "hard"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kids: return String(localized: "Kids")
        case .medium: return String(localized: "Medium")
        case .hard: return String(localized: "Hard")
        }
    }

    var description: String {
        switch self {
        case .kids: return String(localized: "Simple, everyday words")
        case .medium: return String(localized: "More specific terms")
        case .hard: return String(localized: "Obscure and challenging")
        }
    }

    var icon: String {
        switch self {
        case .kids: return "face.smiling"
        case .medium: return "brain.head.profile"
        case .hard: return "flame.fill"
        }
    }
}
