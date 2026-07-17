import Foundation
import XCTest
@testable import Find_The_Imposter

final class CustomWordServiceTests: XCTestCase {
    func testAddWordTrimsWhitespaceAndNewlines() {
        let defaults = makeDefaults()
        let service = CustomWordService(defaults: defaults)

        let result = service.addWord("  \n  Blue Whale \t ", difficulty: .medium, categoryId: "animals")

        guard case let .added(word) = result else {
            return XCTFail("Expected the trimmed word to be added, got \(result)")
        }
        XCTAssertEqual(word.word, "Blue Whale")
        XCTAssertEqual(word.difficulty, .medium)
        XCTAssertEqual(word.categoryId, "animals")
        XCTAssertEqual(service.customWords, [word])

        let restored = CustomWordService(defaults: defaults)
        XCTAssertEqual(restored.customWords, [word])
    }

    func testAddWordRejectsEmptyInput() {
        let service = CustomWordService(defaults: makeDefaults())

        XCTAssertEqual(service.addWord("   \n\t", difficulty: .kids), .empty)
        XCTAssertTrue(service.customWords.isEmpty)
    }

    func testAddWordRejectsCaseInsensitiveDuplicate() {
        let service = CustomWordService(defaults: makeDefaults())

        guard case .added = service.addWord("Otter", difficulty: .kids) else {
            return XCTFail("Expected the first word to be added")
        }

        XCTAssertEqual(service.addWord("  OTTER \n", difficulty: .hard), .duplicate)
        XCTAssertEqual(service.wordCount, 1)
    }

    func testAddWordRejectsDiacriticInsensitiveDuplicate() {
        let service = CustomWordService(defaults: makeDefaults())

        guard case .added = service.addWord("Café", difficulty: .kids) else {
            return XCTFail("Expected the first word to be added")
        }

        XCTAssertEqual(service.addWord("  CAFE\u{301} \n", difficulty: .hard), .duplicate)
        XCTAssertEqual(service.wordCount, 1)
    }

    func testAddWordRejectsMoreThanFiftyCharacters() {
        let service = CustomWordService(defaults: makeDefaults())
        let word = String(repeating: "👨‍👩‍👧‍👦", count: Constants.maxCustomWordLength + 1)
        XCTAssertEqual(word.count, 51)

        XCTAssertEqual(
            service.addWord(word, difficulty: .hard),
            .tooLong(maximum: Constants.maxCustomWordLength)
        )
        XCTAssertTrue(service.customWords.isEmpty)
    }

    func testAddWordAcceptsFiftyUserPerceivedCharacters() {
        let service = CustomWordService(defaults: makeDefaults())
        let word = String(repeating: "👨‍👩‍👧‍👦", count: Constants.maxCustomWordLength)
        XCTAssertEqual(word.count, 50)

        guard case let .added(addedWord) = service.addWord(word, difficulty: .hard) else {
            return XCTFail("Expected a 50-character word to be accepted")
        }
        XCTAssertEqual(addedWord.word, word)
    }

    func testLegacyWordDecodesWithoutCategory() throws {
        let legacyJSON = """
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "word": "Legacy Word",
          "difficulty": "kids"
        }
        """

        let decoded = try JSONDecoder().decode(CustomWord.self, from: Data(legacyJSON.utf8))

        XCTAssertEqual(decoded.word, "Legacy Word")
        XCTAssertEqual(decoded.difficulty, .kids)
        XCTAssertNil(decoded.categoryId)
    }

    func testInvalidLegacyEntriesRemainStoredButAreExcludedFromGameplay() throws {
        let defaults = makeDefaults()
        let rawWords = [
            CustomWord(word: " \n\t ", difficulty: .kids),
            CustomWord(word: " Café ", difficulty: .kids, categoryId: "food"),
            CustomWord(word: "cafe", difficulty: .medium),
            CustomWord(
                word: String(repeating: "A", count: Constants.maxCustomWordLength + 1),
                difficulty: .hard
            ),
            CustomWord(word: "  Apple\n", difficulty: .hard)
        ]
        let storedData = try JSONEncoder().encode(rawWords)
        defaults.set(storedData, forKey: "customWords")

        let service = CustomWordService(defaults: defaults)

        XCTAssertEqual(service.customWords, rawWords)
        XCTAssertEqual(service.usableWords.map(\.word), ["Café", "Apple"])
        XCTAssertEqual(service.usableWords.map(\.categoryId), ["food", nil])
        XCTAssertEqual(service.words(for: [.kids, .medium, .hard]).map(\.word), ["Café", "Apple"])
        XCTAssertEqual(service.wordStrings(for: .kids), ["Café"])
        XCTAssertEqual(service.wordCount, 2)
        XCTAssertTrue(service.hasWords)
        XCTAssertEqual(defaults.data(forKey: "customWords"), storedData)
    }

    func testOnlyInvalidLegacyEntriesDoNotEnableCustomWords() throws {
        let defaults = makeDefaults()
        let rawWords = [
            CustomWord(word: " \n ", difficulty: .kids),
            CustomWord(
                word: String(repeating: "A", count: Constants.maxCustomWordLength + 1),
                difficulty: .hard
            )
        ]
        defaults.set(try JSONEncoder().encode(rawWords), forKey: "customWords")

        let service = CustomWordService(defaults: defaults)

        XCTAssertEqual(service.customWords, rawWords)
        XCTAssertTrue(service.usableWords.isEmpty)
        XCTAssertEqual(service.wordCount, 0)
        XCTAssertFalse(service.hasWords)
    }

    func testTaggedWordReturnsItsBuiltInCategoryForHints() {
        let service = CustomWordService(defaults: makeDefaults())

        let result = service.addWord("Otter", difficulty: .kids, categoryId: "animals")

        guard case let .added(word) = result else {
            return XCTFail("Expected the tagged word to be added, got \(result)")
        }
        XCTAssertEqual(word.categoryId, "animals")
        XCTAssertEqual(service.usableWords.first?.categoryId, "animals")
    }
}
