import XCTest
@testable import Find_The_Imposter

private struct MaxRandomNumberGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 { UInt64.max }
}

final class GameViewModelTests: XCTestCase {
    func testPlayerValidationRejectsBlankDuplicateAndLongNames() {
        let viewModel = makeViewModel()

        viewModel.players = [Player(name: "Alex"), Player(name: "Blair")]
        XCTAssertEqual(viewModel.playerSetupValidation, .notEnoughPlayers)

        viewModel.players = [Player(name: "Alex"), Player(name: " \n\t "), Player(name: "Casey")]
        XCTAssertEqual(viewModel.playerSetupValidation, .blankName)

        viewModel.players = [Player(name: " Alex "), Player(name: "alex"), Player(name: "Casey")]
        XCTAssertEqual(viewModel.playerSetupValidation, .duplicateName)

        viewModel.players = [
            Player(name: "Alex"),
            Player(name: String(repeating: "🙂", count: Constants.maxPlayerNameLength + 1)),
            Player(name: "Casey")
        ]
        XCTAssertEqual(viewModel.playerSetupValidation, .nameTooLong)
    }

    func testPlayerValidationAcceptsThreeUniqueTrimmedNames() {
        let viewModel = makeViewModel()
        viewModel.players = [
            Player(name: "  Alex  "),
            Player(name: "\nBlair\t"),
            Player(name: " Casey\n")
        ]

        XCTAssertEqual(viewModel.playerSetupValidation, .valid)

        viewModel.proceedToSettings()

        XCTAssertEqual(viewModel.players.map(\.name), ["Alex", "Blair", "Casey"])
        XCTAssertEqual(viewModel.gamePhase, .gameSettings)
    }

    func testGameStartValidationDistinguishesMissingDifficultyCategoryAndWords() {
        let viewModel = makeViewModel()
        guard let category = viewModel.wordDataService.categories.first else {
            return XCTFail("Expected bundled word data to contain a category")
        }

        viewModel.settings.selectedDifficulties = []
        viewModel.settings.selectedCategoryIds = [category.id]
        XCTAssertEqual(viewModel.gameStartValidation, .noDifficulty)

        viewModel.settings.selectedDifficulties = [.kids]
        viewModel.settings.selectedCategoryIds = []
        XCTAssertEqual(viewModel.gameStartValidation, .noCategory)

        viewModel.settings.selectedCategoryIds = ["missing-category"]
        XCTAssertEqual(viewModel.gameStartValidation, .noAvailableWords)

        viewModel.settings.selectedCategoryIds = [category.id]
        XCTAssertEqual(viewModel.gameStartValidation, .ready)
        XCTAssertTrue(viewModel.canStartGame)
    }

    func testOnlyIfStartsHintWorksWhenImposterStarts() {
        let viewModel = makeViewModel()
        viewModel.players = [
            Player(name: "Alex"),
            Player(name: "Blair"),
            Player(name: "Casey", isImposter: true)
        ]
        var generator = MaxRandomNumberGenerator()
        viewModel.selectStartingPlayer(using: &generator)

        viewModel.settings.hintMode = .onlyIfStarts
        XCTAssertEqual(viewModel.startingPlayerIndex, 2)
        XCTAssertTrue(viewModel.imposterGetsHint(for: viewModel.players[2]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[0]))

        viewModel.settings.hintMode = .off
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[2]))

        viewModel.settings.hintMode = .always
        XCTAssertTrue(viewModel.imposterGetsHint(for: viewModel.players[2]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[0]))
    }

    func testStartingPlayerCandidatesIncludeEveryPlayer() {
        let viewModel = makeViewModel()
        viewModel.players = [
            Player(name: "Alex"),
            Player(name: "Blair"),
            Player(name: "Casey", isImposter: true)
        ]
        var generator = MaxRandomNumberGenerator()

        viewModel.selectStartingPlayer(using: &generator)

        XCTAssertEqual(viewModel.startingPlayerIndex, viewModel.players.indices.last)
        XCTAssertTrue(viewModel.startingPlayer?.isImposter == true)
    }

    func testCancelRoleRevealClearsSecretStateAndPreservesSetup() {
        let viewModel = makeViewModel()
        guard let category = viewModel.wordDataService.categories.first else {
            return XCTFail("Expected bundled word data to contain a category")
        }
        viewModel.players = [
            Player(name: "Alex", isImposter: true, hasRevealedRole: true),
            Player(name: "Blair", hasRevealedRole: true),
            Player(name: "Casey")
        ]
        viewModel.imposterCount = 2
        viewModel.settings.selectedDifficulties = [.medium]
        viewModel.settings.selectedCategoryIds = [category.id]
        viewModel.settings.hintMode = .always
        viewModel.currentRevealIndex = 1
        viewModel.selectedWord = "Secret"
        viewModel.selectedCategory = category
        viewModel.startingPlayerIndex = 2
        viewModel.isCardFlipped = true
        viewModel.showPassPhoneScreen = false
        viewModel.showImposterReveal = true
        viewModel.showWordReveal = true
        viewModel.cameFromEndGame = true
        viewModel.gamePhase = .roleReveal

        viewModel.cancelRoleReveal()

        XCTAssertEqual(viewModel.players.map(\.name), ["Alex", "Blair", "Casey"])
        XCTAssertTrue(viewModel.players.allSatisfy { !$0.isImposter && !$0.hasRevealedRole })
        XCTAssertEqual(viewModel.imposterCount, 2)
        XCTAssertEqual(viewModel.settings.selectedDifficulties, [.medium])
        XCTAssertEqual(viewModel.settings.selectedCategoryIds, [category.id])
        XCTAssertEqual(viewModel.settings.hintMode, .always)
        XCTAssertEqual(viewModel.currentRevealIndex, 0)
        XCTAssertEqual(viewModel.selectedWord, "")
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertEqual(viewModel.startingPlayerIndex, 0)
        XCTAssertFalse(viewModel.isCardFlipped)
        XCTAssertTrue(viewModel.showPassPhoneScreen)
        XCTAssertFalse(viewModel.showImposterReveal)
        XCTAssertFalse(viewModel.showWordReveal)
        XCTAssertFalse(viewModel.cameFromEndGame)
        XCTAssertEqual(viewModel.gamePhase, .gameSettings)
    }

    private func makeViewModel() -> GameViewModel {
        let settings = GameSettings(defaults: makeDefaults())
        settings.soundEnabled = false
        settings.hapticsEnabled = false
        return GameViewModel(settings: settings)
    }
}
