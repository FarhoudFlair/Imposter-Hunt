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
    enum AddWordResult: Equatable {
        case added(CustomWord)
        case empty
        case tooLong(maximum: Int)
        case duplicate
    }

    /// Category ID used for the My Words chip and selection storage
    static let customCategoryId = "custom"

    private let defaults: UserDefaults
    private let storageKey = "customWords"
    
    // MARK: - In-Memory Backing Storage
    
    private var _customWords: [CustomWord]
    
    // MARK: - Initialization
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        _customWords = Self.loadWords(from: defaults)
    }
    
    // MARK: - Public Properties
    
    var customWords: [CustomWord] {
        get { _customWords }
        set {
            _customWords = newValue
            saveWords()
        }
    }

    /// Valid, normalized words available to the game. Accessing this view does
    /// not rewrite legacy storage or delete unusable entries.
    var usableWords: [CustomWord] {
        var normalizedWords = Set<String>()

        return _customWords.compactMap { storedWord in
            let trimmedWord = storedWord.word.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedWord.isEmpty,
                  trimmedWord.count <= Constants.maxCustomWordLength else {
                return nil
            }

            let normalizedWord = Self.normalized(trimmedWord)
            guard normalizedWords.insert(normalizedWord).inserted else {
                return nil
            }

            var usableWord = storedWord
            usableWord.word = trimmedWord
            return usableWord
        }
    }

    var wordCount: Int {
        usableWords.count
    }

    var hasWords: Bool {
        !usableWords.isEmpty
    }
    
    // MARK: - Word Management

    /// Add a new custom word, optionally tagged with a built-in category for hints
    @discardableResult
    func addWord(_ word: String, difficulty: Difficulty, categoryId: String? = nil) -> AddWordResult {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return .empty }
        guard trimmedWord.count <= Constants.maxCustomWordLength else {
            return .tooLong(maximum: Constants.maxCustomWordLength)
        }

        let normalizedWord = Self.normalized(trimmedWord)
        guard !usableWords.contains(where: { Self.normalized($0.word) == normalizedWord }) else {
            return .duplicate
        }

        let newWord = CustomWord(word: trimmedWord, difficulty: difficulty, categoryId: categoryId)
        _customWords.append(newWord)
        saveWords()
        return .added(newWord)
    }

    /// Remove a word at a specific raw-storage index.
    func removeWord(at index: Int) {
        guard _customWords.indices.contains(index) else { return }
        _customWords.remove(at: index)
        saveWords()
    }

    /// Remove a word by its ID
    func removeWord(id: UUID) {
        _customWords.removeAll { $0.id == id }
        saveWords()
    }

    /// Get usable words for one difficulty.
    func words(for difficulty: Difficulty) -> [CustomWord] {
        words(for: [difficulty])
    }

    /// Get all words for the specified difficulties
    func words(for difficulties: Set<Difficulty>) -> [CustomWord] {
        usableWords.filter { difficulties.contains($0.difficulty) }
    }

    /// Get usable word strings for one difficulty.
    func wordStrings(for difficulty: Difficulty) -> [String] {
        words(for: difficulty).map(\.word)
    }

    /// Get all word strings for the specified difficulties
    func wordStrings(for difficulties: Set<Difficulty>) -> [String] {
        words(for: difficulties).map { $0.word }
    }

    private static func normalized(_ word: String) -> String {
        word.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )
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
