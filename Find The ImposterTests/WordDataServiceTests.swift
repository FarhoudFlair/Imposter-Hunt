import Foundation
import XCTest
@testable import Find_The_Imposter

final class WordDataServiceTests: XCTestCase {
    func testWordBankHasExpectedCategoryAndWordCounts() {
        let service = WordDataService()

        XCTAssertEqual(service.categories.count, 23)
        XCTAssertEqual(service.categories.reduce(0) { total, category in
            total + Difficulty.allCases.reduce(0) {
                $0 + category.words(for: $1).count
            }
        }, 2_070)
    }

    func testEveryDifficultyBucketHasThirtyNonEmptyUniqueEntries() {
        let service = WordDataService()

        for category in service.categories {
            for difficulty in Difficulty.allCases {
                let words = category.words(for: difficulty)
                let normalizedWords = words.map(normalized)
                let bucket = "\(category.id)/\(difficulty.rawValue)"

                XCTAssertEqual(words.count, 30, "\(bucket) must contain 30 entries")
                XCTAssertTrue(
                    normalizedWords.allSatisfy { !$0.isEmpty },
                    "\(bucket) must not contain empty entries"
                )
                XCTAssertEqual(
                    Set(normalizedWords).count,
                    words.count,
                    "\(bucket) must not contain duplicate entries"
                )
            }
        }
    }

    func testCategoryIdentifiersAreUnique() {
        let identifiers = WordDataService().categories.map { normalized($0.id) }

        XCTAssertEqual(Set(identifiers).count, identifiers.count)
    }

    func testPeopleCategoriesContainNinetyNamesWithoutCrossCategoryOverlap() throws {
        let categories = WordDataService().categories
        let peopleCategoryIds = ["creators", "athletes", "celebrities"]
        var previouslySeenNames = Set<String>()

        for categoryId in peopleCategoryIds {
            let category = try XCTUnwrap(
                categories.first { $0.id == categoryId },
                "Missing \(categoryId) category"
            )
            let normalizedNames = category.allWords.map(normalized)
            let uniqueNames = Set(normalizedNames)

            XCTAssertEqual(category.allWords.count, 90, "\(categoryId) must contain 90 names")
            XCTAssertEqual(uniqueNames.count, 90, "\(categoryId) names must be unique")
            XCTAssertTrue(
                previouslySeenNames.isDisjoint(with: uniqueNames),
                "\(categoryId) must not overlap another people category"
            )
            previouslySeenNames.formUnion(uniqueNames)
        }

        XCTAssertEqual(previouslySeenNames.count, 270)
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .current
            )
    }
}
