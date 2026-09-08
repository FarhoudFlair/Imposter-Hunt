import XCTest
@testable import Find_The_Imposter

final class ProjectConfigurationTests: XCTestCase {
    func testApplicationModuleLoads() {
        XCTAssertEqual(Constants.minPlayers, 3)
        XCTAssertEqual(Constants.maxPlayers, 12)
    }
}
