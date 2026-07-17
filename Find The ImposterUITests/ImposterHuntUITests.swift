import XCTest

final class ImposterHuntUITests: XCTestCase {
    private func makeApp(hasSeenOnboarding: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-hasSeenOnboarding", hasSeenOnboarding ? "YES" : "NO",
            "-soundEnabled", "NO",
            "-hapticsEnabled", "NO"
        ]
        return app
    }

    func testHomeScreenLaunches() {
        let app = makeApp()
        app.launch()
        XCTAssertTrue(app.buttons["Start Game"].waitForExistence(timeout: 5))
    }
}
