import XCTest
@testable import Find_The_Imposter

private struct FixedRandomNumberGenerator: RandomNumberGenerator {
    let value: UInt64

    mutating func next() -> UInt64 { value }
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

    func testPlayerNameLengthAcceptsTwentyFourCharactersAndRejectsTwentyFive() {
        let viewModel = makeViewModel()
        let boundaryName = String(repeating: "👨‍👩‍👧‍👦", count: Constants.maxPlayerNameLength)
        XCTAssertEqual(boundaryName.count, 24)
        viewModel.players = [Player(name: "Alex"), Player(name: boundaryName), Player(name: "Casey")]

        XCTAssertEqual(viewModel.playerSetupValidation, .valid)

        viewModel.players[1].name.append("🙂")
        XCTAssertEqual(viewModel.players[1].name.count, 25)
        XCTAssertEqual(viewModel.playerSetupValidation, .nameTooLong)
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
            Player(name: "Alex", isImposter: true),
            Player(name: "Blair"),
            Player(name: "Casey", isImposter: true)
        ]
        var generator = FixedRandomNumberGenerator(value: UInt64.max)
        viewModel.selectStartingPlayer(using: &generator)

        viewModel.settings.hintMode = .onlyIfStarts
        XCTAssertEqual(viewModel.startingPlayerIndex, 2)
        XCTAssertTrue(viewModel.imposterGetsHint(for: viewModel.players[2]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[0]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[1]))

        viewModel.settings.hintMode = .off
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[2]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[0]))

        viewModel.settings.hintMode = .always
        XCTAssertTrue(viewModel.imposterGetsHint(for: viewModel.players[2]))
        XCTAssertTrue(viewModel.imposterGetsHint(for: viewModel.players[0]))
        XCTAssertFalse(viewModel.imposterGetsHint(for: viewModel.players[1]))
    }

    func testStartingPlayerCandidatesIncludeEveryPlayer() {
        let viewModel = makeViewModel()
        viewModel.players = [
            Player(name: "Alex"),
            Player(name: "Blair"),
            Player(name: "Casey", isImposter: true)
        ]
        let cases: [(value: UInt64, expectedIndex: Int)] = [
            (1, 0),
            (UInt64.max / 2, 1),
            (UInt64.max, 2)
        ]

        for testCase in cases {
            var generator = FixedRandomNumberGenerator(value: testCase.value)
            viewModel.selectStartingPlayer(using: &generator)
            XCTAssertEqual(viewModel.startingPlayerIndex, testCase.expectedIndex)
        }

        XCTAssertTrue(viewModel.players[2].isImposter)
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

    func testTaggedCustomWordUsesItsBuiltInCategoryForHints() {
        let defaults = makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)
        guard let category = viewModel.wordDataService.categories.first else {
            return XCTFail("Expected bundled word data to contain a category")
        }
        guard case .added = viewModel.customWordService.addWord(
            "Task Three Tagged Word",
            difficulty: .kids,
            categoryId: category.id
        ) else {
            return XCTFail("Expected the custom word to be added")
        }
        viewModel.players = [Player(name: "Alex"), Player(name: "Blair"), Player(name: "Casey")]
        viewModel.settings.selectedDifficulties = [.kids]
        viewModel.settings.selectedCategoryIds = [CustomWordService.customCategoryId]
        viewModel.settings.hintMode = .always

        viewModel.assignRoles()

        XCTAssertEqual(viewModel.selectedWord, "Task Three Tagged Word")
        XCTAssertEqual(viewModel.selectedCategory, category)
        guard let imposter = viewModel.players.first(where: \.isImposter) else {
            return XCTFail("Expected an assigned imposter")
        }
        XCTAssertTrue(viewModel.imposterGetsHint(for: imposter))
        XCTAssertTrue(viewModel.shouldShowCategoryHint(for: imposter))
    }

    func testUntaggedCustomWordHasNoSyntheticCategoryHint() {
        let defaults = makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)
        guard case .added = viewModel.customWordService.addWord("Task Three Untagged Word", difficulty: .kids) else {
            return XCTFail("Expected the custom word to be added")
        }
        viewModel.players = [Player(name: "Alex"), Player(name: "Blair"), Player(name: "Casey")]
        viewModel.settings.selectedDifficulties = [.kids]
        viewModel.settings.selectedCategoryIds = [CustomWordService.customCategoryId]
        viewModel.settings.hintMode = .always

        viewModel.assignRoles()

        XCTAssertEqual(viewModel.selectedWord, "Task Three Untagged Word")
        XCTAssertNil(viewModel.selectedCategory)
        guard let imposter = viewModel.players.first(where: \.isImposter) else {
            return XCTFail("Expected an assigned imposter")
        }
        XCTAssertTrue(viewModel.imposterGetsHint(for: imposter))
        XCTAssertFalse(viewModel.shouldShowCategoryHint(for: imposter))
    }

    func testUnknownCustomCategoryIdentifierHasNoHint() {
        let defaults = makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)
        guard case .added = viewModel.customWordService.addWord(
            "Task Three Unknown Category",
            difficulty: .kids,
            categoryId: "missing-category"
        ) else {
            return XCTFail("Expected the custom word to be added")
        }
        viewModel.players = [Player(name: "Alex"), Player(name: "Blair"), Player(name: "Casey")]
        viewModel.settings.selectedDifficulties = [.kids]
        viewModel.settings.selectedCategoryIds = [CustomWordService.customCategoryId]
        viewModel.settings.hintMode = .always

        viewModel.assignRoles()

        XCTAssertNil(viewModel.selectedCategory)
        guard let imposter = viewModel.players.first(where: \.isImposter) else {
            return XCTFail("Expected an assigned imposter")
        }
        XCTAssertFalse(viewModel.shouldShowCategoryHint(for: imposter))
    }

    private func makeViewModel(defaults: UserDefaults? = nil) -> GameViewModel {
        let defaults = defaults ?? makeDefaults()
        let settings = GameSettings(defaults: defaults)
        settings.soundEnabled = false
        settings.hapticsEnabled = false
        return GameViewModel(
            settings: settings,
            customWordService: CustomWordService(defaults: defaults)
        )
    }
}
