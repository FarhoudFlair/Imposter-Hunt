//
//  GameViewModel.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Central state manager for the game
@Observable
class GameViewModel {
    enum PlayerSetupValidation: Equatable {
        case valid
        case notEnoughPlayers
        case blankName
        case duplicateName
        case nameTooLong

        var message: String? {
            switch self {
            case .valid:
                return nil
            case .notEnoughPlayers:
                return "Add at least \(Constants.minPlayers) players"
            case .blankName:
                return "Enter a name for every player"
            case .duplicateName:
                return "Player names must be unique"
            case .nameTooLong:
                return "Keep names to \(Constants.maxPlayerNameLength) characters or fewer"
            }
        }
    }

    enum GameStartValidation: Equatable {
        case ready
        case noDifficulty
        case noCategory
        case noAvailableWords

        var message: String? {
            switch self {
            case .ready:
                return nil
            case .noDifficulty:
                return "Select at least one difficulty"
            case .noCategory:
                return "Select at least one category"
            case .noAvailableWords:
                return "No words match the selected settings"
            }
        }
    }

    // MARK: - Game State

    var gamePhase: GamePhase = .home
    var players: [Player] = []
    var imposterCount: Int = 1
    var currentRevealIndex: Int = 0
    var selectedWord: String = ""
    var selectedCategory: Category?
    var startingPlayerIndex: Int = 0

    // MARK: - UI State

    var showSettings: Bool = false
    var isCardFlipped: Bool = false
    var showPassPhoneScreen: Bool = true
    var showImposterReveal: Bool = false
    var showWordReveal: Bool = false
    var cameFromEndGame: Bool = false

    // MARK: - Dependencies

    let settings: GameSettings
    let wordDataService: WordDataService
    let audioService: AudioService
    let hapticsService: HapticsService
    let customWordService: CustomWordService

    // MARK: - Initialization

    init(
        settings: GameSettings = GameSettings(),
        wordDataService: WordDataService = WordDataService(),
        audioService: AudioService = AudioService(),
        hapticsService: HapticsService = HapticsService(),
        customWordService: CustomWordService = CustomWordService()
    ) {
        self.settings = settings
        self.wordDataService = wordDataService
        self.audioService = audioService
        self.hapticsService = hapticsService
        self.customWordService = customWordService
        syncSettingsToServices()
    }

    // MARK: - Computed Properties

    var currentPlayer: Player? {
        guard currentRevealIndex < players.count else { return nil }
        return players[currentRevealIndex]
    }

    var allPlayersRevealed: Bool {
        currentRevealIndex >= players.count
    }

    var imposters: [Player] {
        players.filter { $0.isImposter }
    }

    var nonImposters: [Player] {
        players.filter { !$0.isImposter }
    }

    var startingPlayer: Player? {
        guard startingPlayerIndex < players.count else { return nil }
        return players[startingPlayerIndex]
    }

    var playerSetupValidation: PlayerSetupValidation {
        guard players.count >= Constants.minPlayers else { return .notEnoughPlayers }

        let names = players.map(\.trimmedName)
        guard names.allSatisfy({ !$0.isEmpty }) else { return .blankName }
        guard names.allSatisfy({ $0.count <= Constants.maxPlayerNameLength }) else { return .nameTooLong }

        for (index, name) in names.enumerated() {
            let hasDuplicate = names[..<index].contains {
                $0.localizedCaseInsensitiveCompare(name) == .orderedSame
            }
            if hasDuplicate {
                return .duplicateName
            }
        }

        return .valid
    }

    var canProceedToGameSettings: Bool {
        playerSetupValidation == .valid
    }

    var maxImposters: Int {
        max(1, players.count - 2)
    }

    /// Determines if the current imposter should get a category hint
    /// Based on hint mode: off (never), always (all imposters), onlyIfStarts (starting imposter only)
    func imposterGetsHint(for player: Player) -> Bool {
        guard player.isImposter else { return false }

        switch settings.hintMode {
        case .off:
            return false
        case .always:
            return true
        case .onlyIfStarts:
            guard let startPlayer = startingPlayer else { return false }
            return player.id == startPlayer.id
        }
    }

    var gameStartValidation: GameStartValidation {
        guard settings.hasDifficultySelected else { return .noDifficulty }
        guard settings.hasCategorySelected else { return .noCategory }
        guard availableWordCount() > 0 else { return .noAvailableWords }
        return .ready
    }

    var canStartGame: Bool {
        gameStartValidation == .ready
    }

    /// Deprecated: Use canStartGame instead
    var hasValidCategorySelection: Bool {
        canStartGame
    }

    /// Total words available for the current category + difficulty selection (includes My Words)
    func availableWordCount() -> Int {
        guard !settings.selectedDifficulties.isEmpty else { return 0 }
        guard !settings.selectedCategoryIds.isEmpty else { return 0 }

        let customId = CustomWordService.customCategoryId
        let regularCategoryIds = settings.selectedCategoryIds.filter { $0 != customId }

        var count = 0
        if !regularCategoryIds.isEmpty {
            count += wordDataService.totalWordCount(
                categoryIds: regularCategoryIds,
                difficulties: settings.selectedDifficulties
            )
        }

        if settings.selectedCategoryIds.contains(customId) {
            count += customWordService.wordStrings(for: settings.selectedDifficulties).count
        }

        return count
    }

    // MARK: - Player Management

    func addPlayer() {
        guard players.count < Constants.maxPlayers else { return }
        players.append(Player(name: ""))
        hapticsService.lightTap()
    }

    func removePlayer(at index: Int) {
        guard players.count > Constants.minPlayers, index < players.count else { return }
        players.remove(at: index)
        // Adjust imposter count if needed
        if imposterCount > maxImposters {
            imposterCount = maxImposters
        }
        hapticsService.mediumTap()
    }

    func updatePlayerName(at index: Int, name: String) {
        guard index < players.count else { return }
        players[index].name = name
    }

    // MARK: - Game Flow

    func startNewGame() {
        players = (0..<Constants.defaultPlayerCount).map { _ in Player(name: "") }
        imposterCount = 1
        gamePhase = .playerSetup
        audioService.play(.buttonTap)
        hapticsService.mediumTap()
    }

    func proceedToSettings() {
        guard canProceedToGameSettings else { return }
        for index in players.indices {
            players[index].name = players[index].trimmedName
        }
        gamePhase = .gameSettings
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func goBackToPlayerSetup() {
        gamePhase = .playerSetup
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func beginRoleReveal() {
        guard canStartGame else {
            hapticsService.warning()
            return
        }

        assignRoles()

        // Do not enter reveal if no word could be selected
        guard !selectedWord.isEmpty else {
            hapticsService.warning()
            return
        }

        selectStartingPlayer()
        currentRevealIndex = 0
        showPassPhoneScreen = true
        isCardFlipped = false
        gamePhase = .roleReveal
        audioService.play(.whoosh)
        hapticsService.mediumTap()
    }

    func assignRoles() {
        // Reset all players to non-imposter
        for i in players.indices {
            players[i].isImposter = false
            players[i].hasRevealedRole = false
        }

        // Shuffle and select imposters
        let shuffledIndices = players.indices.shuffled()
        let actualImposterCount = min(imposterCount, players.count - 1)
        for i in 0..<actualImposterCount {
            players[shuffledIndices[i]].isImposter = true
        }

        // Build word pool from selected categories + difficulties (including My Words)
        let customCategoryId = CustomWordService.customCategoryId
        let hasCustomSelected = settings.selectedCategoryIds.contains(customCategoryId)
        let regularCategoryIds = settings.selectedCategoryIds.filter { $0 != customCategoryId }

        var wordPool: [(word: String, category: Category?)] = []

        if !regularCategoryIds.isEmpty {
            let filteredCategories = wordDataService.categories.filter { regularCategoryIds.contains($0.id) }
            for category in filteredCategories {
                for difficulty in settings.selectedDifficulties {
                    for word in category.words(for: difficulty) {
                        wordPool.append((word: word, category: category))
                    }
                }
            }
        }

        if hasCustomSelected {
            let customWordStrings = customWordService.wordStrings(for: settings.selectedDifficulties)
            let customCategory = Category(
                id: customCategoryId,
                name: "My Words",
                icon: "heart.text.square",
                words: [:]
            )
            for word in customWordStrings {
                wordPool.append((word: word, category: customCategory))
            }
        }

        if let selected = wordPool.randomElement() {
            selectedWord = selected.word
            selectedCategory = selected.category
        } else {
            selectedWord = ""
            selectedCategory = nil
        }
    }

    func selectStartingPlayer() {
        var generator = SystemRandomNumberGenerator()
        selectStartingPlayer(using: &generator)
    }

    func selectStartingPlayer<R: RandomNumberGenerator>(using generator: inout R) {
        guard !players.isEmpty else {
            startingPlayerIndex = 0
            return
        }
        startingPlayerIndex = Int.random(in: players.indices, using: &generator)
    }

    func cancelRoleReveal() {
        for index in players.indices {
            players[index].isImposter = false
            players[index].hasRevealedRole = false
        }
        currentRevealIndex = 0
        selectedWord = ""
        selectedCategory = nil
        startingPlayerIndex = 0
        isCardFlipped = false
        showPassPhoneScreen = true
        showImposterReveal = false
        showWordReveal = false
        cameFromEndGame = false
        gamePhase = .gameSettings
    }

    func playerReady() {
        showPassPhoneScreen = false
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func flipCard() {
        guard !isCardFlipped else { return }
        isCardFlipped = true
        players[currentRevealIndex].hasRevealedRole = true
        audioService.play(.cardFlip)
        hapticsService.mediumTap()
    }

    func moveToNextPlayer() {
        currentRevealIndex += 1
        isCardFlipped = false
        showPassPhoneScreen = true

        if allPlayersRevealed {
            gamePhase = .playing
            audioService.play(.reveal)
            hapticsService.success()
        } else {
            audioService.play(.whoosh)
            hapticsService.lightTap()
        }
    }

    func endGame() {
        gamePhase = .endGame
        showImposterReveal = false
        showWordReveal = false
        audioService.play(.reveal)
        hapticsService.warning()
    }

    func revealImposters() {
        showImposterReveal = true
        audioService.play(.imposterReveal)
        hapticsService.heavyTap()
    }

    func revealWord() {
        showWordReveal = true
        audioService.play(.victory)
        hapticsService.success()
    }

    func playAgain() {
        // Keep same players, reassign roles
        showImposterReveal = false
        showWordReveal = false
        cameFromEndGame = false
        beginRoleReveal()
    }

    func changeSettings() {
        // Go to settings while keeping players
        showImposterReveal = false
        showWordReveal = false
        cameFromEndGame = true
        gamePhase = .gameSettings
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func goBackFromSettings() {
        if cameFromEndGame {
            // Return to end game with reveals ready to show again
            cameFromEndGame = false
            gamePhase = .endGame
            showImposterReveal = false
            showWordReveal = false
        } else {
            gamePhase = .playerSetup
        }
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func returnHome() {
        resetGame()
        gamePhase = .home
        audioService.play(.buttonTap)
        hapticsService.lightTap()
    }

    func resetGame() {
        players = []
        imposterCount = 1
        currentRevealIndex = 0
        selectedWord = ""
        selectedCategory = nil
        startingPlayerIndex = 0
        showPassPhoneScreen = true
        isCardFlipped = false
        showImposterReveal = false
        showWordReveal = false
        cameFromEndGame = false
    }

    // MARK: - Settings Sync

    func syncSettingsToServices() {
        audioService.isEnabled = settings.soundEnabled
        hapticsService.isEnabled = settings.hapticsEnabled
    }

    func toggleSound() {
        settings.soundEnabled.toggle()
        audioService.isEnabled = settings.soundEnabled
        if settings.soundEnabled {
            audioService.play(.buttonTap)
        }
        hapticsService.selection()
    }

    func toggleHaptics() {
        settings.hapticsEnabled.toggle()
        hapticsService.isEnabled = settings.hapticsEnabled
        hapticsService.selection()
    }
}
