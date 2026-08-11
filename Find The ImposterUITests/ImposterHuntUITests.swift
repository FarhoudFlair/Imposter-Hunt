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

    @discardableResult
    private func launchApp() -> XCUIApplication {
        let app = makeApp()
        app.launch()
        XCTAssertTrue(app.buttons["home-start-game"].waitForExistence(timeout: 5))
        return app
    }

    private func enterPlayersAndReachGameSettings(in app: XCUIApplication) {
        app.buttons["home-start-game"].tap()

        for (index, name) in ["Alex", "Blair", "Casey"].enumerated() {
            let field = app.textFields["Player \(index + 1)"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            field.tap()
            field.typeText(name)
        }

        if app.keyboards.buttons["Next"].exists {
            app.keyboards.buttons["Next"].tap()
        }

        let nextButton = app.buttons["player-setup-next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        XCTAssertTrue(nextButton.isEnabled)
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Game Settings"].waitForExistence(timeout: 5))
    }

    private func beginRoleReveal(in app: XCUIApplication) {
        let beginButton = app.buttons["game-settings-begin"]
        XCTAssertTrue(beginButton.waitForExistence(timeout: 5))
        XCTAssertTrue(beginButton.isEnabled)
        beginButton.tap()
        XCTAssertTrue(app.buttons["pass-phone-ready"].waitForExistence(timeout: 5))
    }

    private func revealCurrentRole(in app: XCUIApplication) {
        app.buttons["pass-phone-ready"].tap()

        let revealButton = app.buttons["reveal-role"]
        XCTAssertTrue(revealButton.waitForExistence(timeout: 5))
        revealButton.tap()
    }

    func testHomeScreenLaunches() {
        let app = makeApp()
        app.launch()
        XCTAssertTrue(app.buttons["home-start-game"].waitForExistence(timeout: 5))
    }

    func testDuplicatePlayerNamesCannotContinue() {
        let app = launchApp()
        app.buttons["home-start-game"].tap()

        for (index, name) in ["Alex", "Alex", "Casey"].enumerated() {
            let field = app.textFields["Player \(index + 1)"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            field.tap()
            field.typeText(name)
        }

        if app.keyboards.buttons["Next"].exists {
            app.keyboards.buttons["Next"].tap()
        }

        XCTAssertTrue(app.staticTexts["Player names must be unique"].waitForExistence(timeout: 5))

        let nextButton = app.buttons["player-setup-next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        XCTAssertFalse(nextButton.isEnabled)
    }

    func testRoleCanBeRevealedWithButton() {
        let app = launchApp()
        enterPlayersAndReachGameSettings(in: app)
        beginRoleReveal(in: app)

        revealCurrentRole(in: app)

        XCTAssertTrue(app.buttons["role-reveal-next"].waitForExistence(timeout: 5))
    }

    func testRoleRevealCanReturnToSettings() {
        let app = launchApp()
        enterPlayersAndReachGameSettings(in: app)
        beginRoleReveal(in: app)

        let passScreenBackButton = app.buttons["back-to-settings"]
        XCTAssertTrue(passScreenBackButton.waitForExistence(timeout: 5))
        passScreenBackButton.tap()
        XCTAssertTrue(app.staticTexts["Game Settings"].waitForExistence(timeout: 5))

        beginRoleReveal(in: app)
        revealCurrentRole(in: app)

        let revealedRoleBackButton = app.buttons["back-to-settings"]
        XCTAssertTrue(revealedRoleBackButton.waitForExistence(timeout: 5))
        revealedRoleBackButton.tap()

        let alert = app.alerts["Return to Settings?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts[
            "Revealed roles will be cleared and reassigned when you begin again."
        ].exists)
        XCTAssertTrue(alert.buttons["Keep Playing"].exists)
        alert.buttons["Return to Settings"].tap()

        XCTAssertTrue(app.staticTexts["Game Settings"].waitForExistence(timeout: 5))
    }

    func testSettingsExposeCustomWordsAndPrivacyPolicy() {
        let app = launchApp()
        app.buttons["home-settings"].tap()

        let customWordsButton = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Custom Words")
        ).firstMatch
        XCTAssertTrue(customWordsButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Version 1.0 (2)"].waitForExistence(timeout: 5))

        let privacyPolicyLink = app.buttons["Privacy Policy"]
        XCTAssertTrue(privacyPolicyLink.waitForExistence(timeout: 5))
        for _ in 0..<3 where !privacyPolicyLink.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(privacyPolicyLink.isHittable)
        privacyPolicyLink.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["privacy-policy"].waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.staticTexts["Imposter Hunt works entirely offline."].exists)
        XCTAssertTrue(app.staticTexts["The app has no accounts."].exists)
        XCTAssertTrue(app.staticTexts[
            "The app does not collect, transmit, sell, share, or track personal data."
        ].exists)
        XCTAssertTrue(app.staticTexts[
            "Player names, settings, and custom words remain on the device in UserDefaults."
        ].exists)
        XCTAssertTrue(app.staticTexts["Deleting the app removes its locally stored data."].exists)
        XCTAssertTrue(app.staticTexts[
            "Privacy questions can be sent through the developer contact shown on the App Store listing."
        ].exists)
    }
}
