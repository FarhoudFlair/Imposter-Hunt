//
//  WordDataService.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import Foundation

/// Service for loading and managing word categories
@Observable
class WordDataService {
    private(set) var categories: [Category] = []

    init() {
        loadCategories()
    }

    private func loadCategories() {
        guard let url = Bundle.main.url(forResource: "WordData", withExtension: "json") else {
            print("WordData.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let categoryData = try JSONDecoder().decode(CategoryData.self, from: data)
            categories = categoryData.categories
        } catch {
            print("Failed to load word data: \(error)")
        }
    }

    /// Get a random word from the specified categories and difficulties
    /// - Parameters:
    ///   - categoryIds: Set of category IDs to choose from (empty = all)
    ///   - difficulties: Set of difficulties to include words from
    /// - Returns: A tuple of the selected word and its category, or nil if no valid words
    func getRandomWord(
        from categoryIds: Set<String>,
        difficulties: Set<Difficulty>
    ) -> (word: String, category: Category)? {
        // Filter to selected categories (or all if empty)
        let filteredCategories = categoryIds.isEmpty
            ? categories
            : categories.filter { categoryIds.contains($0.id) }

        // Collect all valid words with their categories
        var wordPool: [(word: String, category: Category)] = []

        for category in filteredCategories {
            for difficulty in difficulties {
                let words = category.words(for: difficulty)
                for word in words {
                    wordPool.append((word: word, category: category))
                }
            }
        }

        return wordPool.randomElement()
    }

    /// Get a random word using a single difficulty (convenience method)
    func getRandomWord(
        from categoryIds: Set<String>,
        difficulty: Difficulty
    ) -> (word: String, category: Category)? {
        getRandomWord(from: categoryIds, difficulties: [difficulty])
    }

    /// Get all words for a specific category and difficulty
    func getWords(categoryId: String, difficulty: Difficulty) -> [String] {
        categories.first { $0.id == categoryId }?.words(for: difficulty) ?? []
    }

    /// Get total word count across all selected categories and difficulties
    func totalWordCount(categoryIds: Set<String>, difficulties: Set<Difficulty>) -> Int {
        let filteredCategories = categoryIds.isEmpty
            ? categories
            : categories.filter { categoryIds.contains($0.id) }

        return filteredCategories.reduce(0) { count, category in
            count + difficulties.reduce(0) { diffCount, difficulty in
                diffCount + category.words(for: difficulty).count
            }
        }
    }
}
