import Foundation
import XCTest
@testable import Find_The_Imposter

extension XCTestCase {
    func makeDefaults() -> UserDefaults {
        let suite = "tests.\(name).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suite)
        }
        return defaults
    }
}

final class GameSettingsTests: XCTestCase {
    func testSettingsPersistInInjectedDefaults() {
        let defaults = makeDefaults()
        let settings = GameSettings(defaults: defaults)
        settings.hintMode = .always
        settings.soundEnabled = false

        let restored = GameSettings(defaults: defaults)
        XCTAssertEqual(restored.hintMode, .always)
        XCTAssertFalse(restored.soundEnabled)
    }
}
