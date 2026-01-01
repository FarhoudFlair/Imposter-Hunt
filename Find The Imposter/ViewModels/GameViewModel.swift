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

    // MARK: - Dependencies

    let settings: GameSettings
    let wordDataService: WordDataService
    let audioService: AudioService
    let hapticsService: HapticsService

    // MARK: - Initialization

    init() {
        self.settings = GameSettings()
        self.wordDataService = WordDataService()
        self.audioService = AudioService()
        self.hapticsService = HapticsService()

        // Sync service states with settings
        audioService.isEnabled = settings.soundEnabled
        hapticsService.isEnabled = settings.hapticsEnabled
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

    /// Checks if players are ready to proceed to game settings (enough players with names)
    var canProceedToGameSettings: Bool {
        players.count >= 3 && players.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
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

    /// Returns true if game can start (has valid difficulty and category selections with available words)
    var canStartGame: Bool {
        // Must have at least one difficulty selected
        guard !settings.selectedDifficulties.isEmpty else { return false }

        // Must have at least one category selected
        guard !settings.selectedCategoryIds.isEmpty else { return false }

        return wordDataService.totalWordCount(
            categoryIds: settings.selectedCategoryIds,
            difficulties: settings.selectedDifficulties
        ) > 0
    }

    /// Deprecated: Use canStartGame instead
    var hasValidCategorySelection: Bool {
        canStartGame
    }

    // MARK: - Player Management

    func addPlayer() {
        guard players.count < 12 else { return }
        players.append(Player(name: ""))
        hapticsService.lightTap()
    }

    func removePlayer(at index: Int) {
        guard players.count > 3, index < players.count else { return }
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
        players = (0..<3).map { _ in Player(name: "") }
        imposterCount = 1
        gamePhase = .playerSetup
        audioService.play(.buttonTap)
        hapticsService.mediumTap()
    }

    func proceedToSettings() {
        guard canStartGame else { return }
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
        assignRoles()
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

        // Select random word from selected categories and difficulties
        if let result = wordDataService.getRandomWord(
            from: settings.selectedCategoryIds,
            difficulties: settings.selectedDifficulties
        ) {
            selectedWord = result.word
            selectedCategory = result.category
        }
    }

    func selectStartingPlayer() {
        // Prefer non-imposter to start
        let nonImposterIndices = players.indices.filter { !players[$0].isImposter }

        if let randomIndex = nonImposterIndices.randomElement() {
            startingPlayerIndex = randomIndex
        } else {
            // All are imposters (shouldn't happen with proper validation)
            startingPlayerIndex = players.indices.randomElement() ?? 0
        }
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
        beginRoleReveal()
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
