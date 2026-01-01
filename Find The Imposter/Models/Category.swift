//
//  Category.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import Foundation

/// A word category containing words organized by difficulty level
struct Category: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let icon: String  // SF Symbol name
    let words: [String: [String]]  // difficulty key -> word array

    var localizedName: String {
        String(localized: String.LocalizationValue(name))
    }

    func words(for difficulty: Difficulty) -> [String] {
        words[difficulty.rawValue] ?? []
    }

    /// Returns all words across all difficulty levels
    var allWords: [String] {
        words.values.flatMap { $0 }
    }
}

/// Container for decoding the word data JSON
struct CategoryData: Codable {
    let categories: [Category]
}
