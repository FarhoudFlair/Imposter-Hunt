//
//  CustomWordService.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import Foundation

/// Service for managing user-created custom words with UserDefaults persistence
@Observable
class CustomWordService {
    /// Category ID used for the My Words chip and selection storage
    static let customCategoryId = "custom"

    private let defaults = UserDefaults.standard
    private let storageKey = "customWords"
    
    // MARK: - In-Memory Backing Storage
    
    private var _customWords: [CustomWord]
    
    // MARK: - Initialization
    
    init() {
        _customWords = Self.loadWords(from: UserDefaults.standard)
    }
    
    // MARK: - Public Properties
    
    var customWords: [CustomWord] {
        get { _customWords }
        set {
            _customWords = newValue
            saveWords()
        }
    }
    
    var wordCount: Int {
        _customWords.count
    }
    
    var hasWords: Bool {
        !_customWords.isEmpty
    }
    
    // MARK: - Word Management
    
    /// Add a new custom word
    func addWord(_ word: String, difficulty: Difficulty) {
        let trimmedWord = word.trimmingCharacters(in: .whitespaces)
        guard !trimmedWord.isEmpty else { return }
        
        let newWord = CustomWord(word: trimmedWord, difficulty: difficulty)
        _customWords.append(newWord)
        saveWords()
    }
    
    /// Remove a word at a specific index
    func removeWord(at index: Int) {
        guard index >= 0 && index < _customWords.count else { return }
        _customWords.remove(at: index)
        saveWords()
    }
    
    /// Remove a word by its ID
    func removeWord(id: UUID) {
        _customWords.removeAll { $0.id == id }
        saveWords()
    }
    
    /// Get words filtered by difficulty
    func words(for difficulty: Difficulty) -> [CustomWord] {
        _customWords.filter { $0.difficulty == difficulty }
    }
    
    /// Get word strings filtered by difficulty
    func wordStrings(for difficulty: Difficulty) -> [String] {
        words(for: difficulty).map { $0.word }
    }
    
    /// Get all word strings for the specified difficulties
    func wordStrings(for difficulties: Set<Difficulty>) -> [String] {
        _customWords
            .filter { difficulties.contains($0.difficulty) }
            .map { $0.word }
    }
    
    // MARK: - Persistence
    
    private static func loadWords(from defaults: UserDefaults) -> [CustomWord] {
        guard let data = defaults.data(forKey: "customWords"),
              let words = try? JSONDecoder().decode([CustomWord].self, from: data) else {
            return []
        }
        return words
    }
    
    private func saveWords() {
        if let data = try? JSONEncoder().encode(_customWords) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
