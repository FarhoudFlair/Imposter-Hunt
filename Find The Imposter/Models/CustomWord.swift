//
//  CustomWord.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import Foundation

/// A user-created custom word for personalized gameplay
struct CustomWord: Codable, Identifiable, Hashable {
    let id: UUID
    var word: String
    var difficulty: Difficulty
    /// Built-in category this word belongs to, used as the imposter's hint.
    /// Optional so words saved before tagging existed still decode; `nil` means
    /// the imposter gets no hint for this word.
    var categoryId: String?

    init(id: UUID = UUID(), word: String, difficulty: Difficulty, categoryId: String? = nil) {
        self.id = id
        self.word = word
        self.difficulty = difficulty
        self.categoryId = categoryId
    }
}
