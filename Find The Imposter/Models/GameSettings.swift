//
//  GameSettings.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Persisted game settings using UserDefaults with in-memory backing for SwiftUI reactivity
@Observable
class GameSettings {
    private let defaults = UserDefaults.standard

    // MARK: - Hint Mode Enum

    enum HintMode: String, CaseIterable {
        case off = "off"
        case always = "always"
        case onlyIfStarts = "onlyIfStarts"

        var displayName: String {
            switch self {
            case .off: return "Off"
            case .always: return "Always"
            case .onlyIfStarts: return "If Starts"
            }
        }

        var description: String {
            switch self {
            case .off: return "Imposters never see the category"
            case .always: return "All imposters see the category hint"
            case .onlyIfStarts: return "Imposter only gets hint if chosen to start first"
            }
        }
    }

    // MARK: - In-Memory Backing Storage (tracked by @Observable)

    private var _selectedDifficulties: Set<Difficulty>
    private var _selectedCategoryIds: Set<String>
    private var _hintMode: HintMode
    private var _soundEnabled: Bool
    private var _hapticsEnabled: Bool

    // MARK: - Initialization

    init() {
        // Load from UserDefaults into in-memory storage
        _selectedDifficulties = Self.loadDifficulties(from: UserDefaults.standard)
        _selectedCategoryIds = Self.loadCategoryIds(from: UserDefaults.standard)
        _hintMode = Self.loadHintMode(from: UserDefaults.standard)
        _soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        _hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    // MARK: - Game Settings Properties

    var hintMode: HintMode {
        get { _hintMode }
        set {
            _hintMode = newValue
            defaults.set(newValue.rawValue, forKey: "hintMode")
        }
    }

    var selectedDifficulties: Set<Difficulty> {
        get { _selectedDifficulties }
        set {
            _selectedDifficulties = newValue
            saveDifficulties(newValue)
        }
    }

    var selectedCategoryIds: Set<String> {
        get { _selectedCategoryIds }
        set {
            _selectedCategoryIds = newValue
            saveCategoryIds(newValue)
        }
    }

    // MARK: - App Settings Properties

    var soundEnabled: Bool {
        get { _soundEnabled }
        set {
            _soundEnabled = newValue
            defaults.set(newValue, forKey: "soundEnabled")
        }
    }

    var hapticsEnabled: Bool {
        get { _hapticsEnabled }
        set {
            _hapticsEnabled = newValue
            defaults.set(newValue, forKey: "hapticsEnabled")
        }
    }

    // MARK: - Static Load Methods

    private static func loadDifficulties(from defaults: UserDefaults) -> Set<Difficulty> {
        guard let data = defaults.data(forKey: "selectedDifficulties"),
              let rawValues = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return Set(Difficulty.allCases) // Default: all difficulties
        }
        return Set(rawValues.compactMap { Difficulty(rawValue: $0) })
    }

    private static func loadCategoryIds(from defaults: UserDefaults) -> Set<String> {
        guard let data = defaults.data(forKey: "selectedCategoryIds"),
              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return [] // Will be initialized with all categories on first use
        }
        return ids
    }

    private static func loadHintMode(from defaults: UserDefaults) -> HintMode {
        // Migration: check for old imposterHintsEnabled setting
        if let rawValue = defaults.string(forKey: "hintMode"),
           let mode = HintMode(rawValue: rawValue) {
            return mode
        }
        // Migrate from old boolean setting
        if defaults.object(forKey: "imposterHintsEnabled") != nil {
            let oldValue = defaults.bool(forKey: "imposterHintsEnabled")
            return oldValue ? .always : .onlyIfStarts
        }
        return .onlyIfStarts // Default
    }

    // MARK: - Save Methods

    private func saveDifficulties(_ difficulties: Set<Difficulty>) {
        let rawValues = Set(difficulties.map { $0.rawValue })
        if let data = try? JSONEncoder().encode(rawValues) {
            defaults.set(data, forKey: "selectedDifficulties")
        }
    }

    private func saveCategoryIds(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids) {
            defaults.set(data, forKey: "selectedCategoryIds")
        }
    }

    // MARK: - Category Initialization

    /// Initialize categories with all IDs if not yet set
    func initializeCategoriesIfNeeded(allIds: Set<String>) {
        if _selectedCategoryIds.isEmpty && defaults.data(forKey: "selectedCategoryIds") == nil {
            selectedCategoryIds = allIds
        }
    }

    // MARK: - Computed Helpers

    var allDifficultiesSelected: Bool {
        _selectedDifficulties.count == Difficulty.allCases.count
    }

    func allCategoriesSelected(totalCount: Int) -> Bool {
        _selectedCategoryIds.count == totalCount
    }

    var hasDifficultySelected: Bool {
        !_selectedDifficulties.isEmpty
    }

    var hasCategorySelected: Bool {
        !_selectedCategoryIds.isEmpty
    }

    // MARK: - Toggle Methods

    func toggleDifficulty(_ difficulty: Difficulty) {
        if _selectedDifficulties.contains(difficulty) {
            _selectedDifficulties.remove(difficulty)
        } else {
            _selectedDifficulties.insert(difficulty)
        }
        saveDifficulties(_selectedDifficulties)
    }

    func toggleCategory(_ categoryId: String) {
        if _selectedCategoryIds.contains(categoryId) {
            _selectedCategoryIds.remove(categoryId)
        } else {
            _selectedCategoryIds.insert(categoryId)
        }
        saveCategoryIds(_selectedCategoryIds)
    }

    // MARK: - Select All Methods

    func selectAllCategories(allIds: Set<String>) {
        selectedCategoryIds = allIds
    }

    func selectAllDifficulties() {
        selectedDifficulties = Set(Difficulty.allCases)
    }
}
