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
    
    init(id: UUID = UUID(), word: String, difficulty: Difficulty) {
        self.id = id
        self.word = word
        self.difficulty = difficulty
    }
}
