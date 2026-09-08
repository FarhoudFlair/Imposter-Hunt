# Imposter Hunt App Store Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Produce a tested, accessible, privacy-complete, iPhone-only Imposter Hunt 1.0 release with a curated 2,070-word bank and local App Store submission package.

**Architecture:** Preserve the existing SwiftUI MVVM design with one environment-injected GameViewModel and local UserDefaults-backed services. Add dependency injection only at persistence and randomness boundaries so production behavior stays simple while unit tests remain deterministic. Keep the word bank as bundled static JSON and add no networking or third-party dependencies.

**Tech Stack:** Swift 5, SwiftUI, Observation, XCTest, XCUITest, Xcode 26.6, iOS 17.0 deployment target, iOS 26.5 simulator.

## Global Constraints

- Preserve all user-owned uncommitted changes; never reset, discard, or overwrite them.
- Target iPhone only in portrait orientation with iOS 17.0 or later.
- Retain bundle identifier FarhoudTalebi.Find-The-Imposter and display name Imposter Hunt.
- Set marketing version 1.0 and build number 2.
- Keep the app local and offline: no networking, analytics, advertising, accounts, monetization, multiplayer, or external dependencies.
- Do not delete the three source-art PNG files; exclude them from the target and built bundle.
- Do not expose My Words, Unknown, or another synthetic category as an imposter hint.
- Preserve every existing category/difficulty bucket at exactly 30 entries.
- Add creators, athletes, and celebrities with exactly 30 kids, 30 medium, and 30 hard entries each.
- The final built-in bank must contain exactly 23 categories and 2,070 non-empty entries.
- Public-figure categories use static names only and contain no images, logos, quotations, political figures, endorsement wording, or runtime lookup.
- All production behavior changes follow red-green TDD. Project configuration, documentation, and image verification use focused mechanical checks because they are not executable behavior.
- No App Store Connect mutation or PR merge occurs during implementation.

---

### Task 1: Release configuration and repeatable test targets

**Files:**
- Modify: Find The Imposter.xcodeproj/project.pbxproj
- Create: Find The Imposter.xcodeproj/xcshareddata/xcschemes/Find The Imposter.xcscheme
- Create: Find The ImposterTests/ProjectConfigurationTests.swift
- Create: Find The ImposterUITests/ImposterHuntUITests.swift
- Preserve: Find The Imposter/Assets.xcassets/AppIcon.appiconset/AppIcon.png
- Preserve: Find The Imposter/PrivacyInfo.xcprivacy

**Interfaces:**
- Consumes: Existing application target Find The Imposter and module Find_The_Imposter.
- Produces: Shared scheme Find The Imposter with unit and UI test actions; test targets Find The ImposterTests and Find The ImposterUITests.

- [ ] **Step 1: Record the baseline and inspect existing project changes**

Run:

~~~bash
git status --short
git diff -- "Find The Imposter.xcodeproj/project.pbxproj"
xcodebuild -list -project "Find The Imposter.xcodeproj"
~~~

Expected: branch prepare-app-store; the project diff contains the existing orientation edits; one app target and no test targets are listed.

- [ ] **Step 2: Add the two test targets and shared scheme**

Patch project.pbxproj so:

- Find The ImposterTests is a unit-test bundle hosted by Find The Imposter.
- Find The ImposterUITests is a UI-test bundle targeting Find The Imposter.
- Both targets use iOS 17.0, automatic signing, the existing team, Swift 5.0, and unique bundle identifiers derived from FarhoudTalebi.Find-The-Imposter.
- The app target remains a dependency of both tests.
- The shared scheme builds the app and both tests and includes both targets in TestAction.

Create this initial unit test:

~~~swift
import XCTest
@testable import Find_The_Imposter

final class ProjectConfigurationTests: XCTestCase {
    func testApplicationModuleLoads() {
        XCTAssertEqual(Constants.minPlayers, 3)
        XCTAssertEqual(Constants.maxPlayers, 12)
    }
}
~~~

Create this initial UI test shell:

~~~swift
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
~~~

- [ ] **Step 3: Apply release build settings**

Set the application target Debug and Release configurations to:

~~~text
CURRENT_PROJECT_VERSION = 2
MARKETING_VERSION = 1.0
TARGETED_DEVICE_FAMILY = 1
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait
~~~

Remove INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad. Add a PBXFileSystemSynchronizedBuildFileExceptionSet that excludes these files from target membership without deleting them:

~~~text
Resources/SuperZoomedAPpIcon.png
Resources/MoreZoomedAppIcon.png
Resources/ChatGPT Image Dec 31, 2025 at 03_16_02 AM.png
~~~

- [ ] **Step 4: Verify the targets and configuration**

Run:

~~~bash
xcodebuild -list -project "Find The Imposter.xcodeproj"
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task1
~~~

Expected: both test targets are listed; ProjectConfigurationTests and testHomeScreenLaunches pass.

- [ ] **Step 5: Commit the configuration task**

Run:

~~~bash
git add "Find The Imposter.xcodeproj/project.pbxproj" "Find The Imposter.xcodeproj/xcshareddata/xcschemes/Find The Imposter.xcscheme" "Find The ImposterTests/ProjectConfigurationTests.swift" "Find The ImposterUITests/ImposterHuntUITests.swift" "Find The Imposter/Assets.xcassets/AppIcon.appiconset/AppIcon.png" "Find The Imposter/PrivacyInfo.xcprivacy"
git commit -m "Configure App Store release and test targets"
~~~

Expected: a focused commit containing the existing icon/manifest release work plus repeatable test infrastructure.

---

### Task 2: Deterministic gameplay rules and validation

**Files:**
- Modify: Find The Imposter/Utilities/Constants.swift
- Modify: Find The Imposter/Models/Player.swift
- Modify: Find The Imposter/Models/GameSettings.swift
- Modify: Find The Imposter/ViewModels/GameViewModel.swift
- Modify: Find The Imposter/Views/PlayerSetup/PlayerRowView.swift
- Modify: Find The Imposter/Views/PlayerSetup/PlayerSetupView.swift
- Modify: Find The Imposter/Views/GameSetup/GameSettingsView.swift
- Create: Find The ImposterTests/GameSettingsTests.swift
- Create: Find The ImposterTests/GameViewModelTests.swift

**Interfaces:**
- Produces: Constants.maxPlayerNameLength = 24.
- Produces: GameSettings.init(defaults: UserDefaults = .standard).
- Produces: GameViewModel.PlayerSetupValidation and GameViewModel.GameStartValidation.
- Produces: GameViewModel.cancelRoleReveal().
- Produces: GameViewModel.selectStartingPlayer(using: inout RandomNumberGenerator).

- [ ] **Step 1: Write failing persistence and validation tests**

Create an isolated defaults helper:

~~~swift
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
~~~

GameSettingsTests must assert:

~~~swift
func testSettingsPersistInInjectedDefaults() {
    let defaults = makeDefaults()
    let settings = GameSettings(defaults: defaults)
    settings.hintMode = .always
    settings.soundEnabled = false

    let restored = GameSettings(defaults: defaults)
    XCTAssertEqual(restored.hintMode, .always)
    XCTAssertFalse(restored.soundEnabled)
}
~~~

GameViewModelTests must cover:

~~~swift
func testPlayerValidationRejectsBlankDuplicateAndLongNames()
func testPlayerValidationAcceptsThreeUniqueTrimmedNames()
func testGameStartValidationDistinguishesMissingDifficultyCategoryAndWords()
func testOnlyIfStartsHintWorksWhenImposterStarts()
func testStartingPlayerCandidatesIncludeEveryPlayer()
func testCancelRoleRevealClearsSecretStateAndPreservesSetup()
~~~

Use a deterministic generator:

~~~swift
struct MaxRandomNumberGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 { UInt64.max }
}
~~~

- [ ] **Step 2: Run the new tests and verify RED**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/GameSettingsTests" -only-testing:"Find The ImposterTests/GameViewModelTests" -derivedDataPath /tmp/imposter-hunt-task2-red
~~~

Expected: compile/test failures because injected defaults, validation enums, deterministic selection, and cancellation do not exist.

- [ ] **Step 3: Inject UserDefaults and implement validation**

GameSettings uses:

~~~swift
private let defaults: UserDefaults

init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    _selectedDifficulties = Self.loadDifficulties(from: defaults)
    _selectedCategoryIds = Self.loadCategoryIds(from: defaults)
    _hintMode = Self.loadHintMode(from: defaults)
    _soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
    _hapticsEnabled = defaults.object(forKey: "hapticsEnabled") as? Bool ?? true
    _hasSeenOnboarding = defaults.bool(forKey: "hasSeenOnboarding")
}
~~~

GameViewModel receives defaulted production dependencies so tests can supply isolated settings and custom-word storage:

~~~swift
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
~~~

Constants adds:

~~~swift
static let maxPlayerNameLength = 24
static let maxCustomWordLength = 50
~~~

GameViewModel adds:

~~~swift
enum PlayerSetupValidation: Equatable {
    case valid
    case notEnoughPlayers
    case blankName
    case duplicateName
    case nameTooLong
}

enum GameStartValidation: Equatable {
    case ready
    case noDifficulty
    case noCategory
    case noAvailableWords
}
~~~

Normalize names with whitespacesAndNewlines, use localizedCaseInsensitiveCompare for duplicate detection, and expose concise user-facing messages. proceedToSettings() trims accepted names before changing phase.

- [ ] **Step 4: Fix starting-player selection and cancellation**

Implement deterministic selection:

~~~swift
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
~~~

Implement cancellation:

~~~swift
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
~~~

- [ ] **Step 5: Connect validation to player and game-settings UI**

PlayerRowView limits binding input to Constants.maxPlayerNameLength user-perceived characters. PlayerSetupView shows the exact validation message and disables Continue unless validation is valid.

GameSettingsView uses GameStartValidation for its warning. Add an alert-backed Back to Settings action only in Task 5; this task exposes the state method.

- [ ] **Step 6: Run focused and full tests and verify GREEN**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/GameSettingsTests" -only-testing:"Find The ImposterTests/GameViewModelTests" -derivedDataPath /tmp/imposter-hunt-task2-green
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task2-full
~~~

Expected: focused and full suites pass with no test failures.

- [ ] **Step 7: Commit gameplay rules**

Run:

~~~bash
git add "Find The Imposter/Utilities/Constants.swift" "Find The Imposter/Models/Player.swift" "Find The Imposter/Models/GameSettings.swift" "Find The Imposter/ViewModels/GameViewModel.swift" "Find The Imposter/Views/PlayerSetup/PlayerRowView.swift" "Find The Imposter/Views/PlayerSetup/PlayerSetupView.swift" "Find The Imposter/Views/GameSetup/GameSettingsView.swift" "Find The ImposterTests/GameSettingsTests.swift" "Find The ImposterTests/GameViewModelTests.swift"
git commit -m "Fix gameplay validation and starting hints"
~~~

---

### Task 3: Safe custom words and in-flow management

**Files:**
- Modify: Find The Imposter/Models/CustomWord.swift
- Modify: Find The Imposter/Services/CustomWordService.swift
- Modify: Find The Imposter/ViewModels/GameViewModel.swift
- Modify: Find The Imposter/Views/CustomWords/AddWordRow.swift
- Modify: Find The Imposter/Views/CustomWords/CustomWordRow.swift
- Modify: Find The Imposter/Views/CustomWords/CustomWordsView.swift
- Modify: Find The Imposter/Views/GameSetup/GameSettingsView.swift
- Modify: Find The Imposter/Views/GameSetup/CategoryPickerView.swift
- Modify: Find The Imposter/Models/Difficulty.swift
- Create: Find The ImposterTests/CustomWordServiceTests.swift

**Interfaces:**
- Produces: CustomWordService.init(defaults: UserDefaults = .standard).
- Produces: CustomWordService.AddWordResult.
- Produces: CustomWordService.addWord(_:difficulty:categoryId:) -> AddWordResult.
- Produces: CustomWordService.usableWords.

- [ ] **Step 1: Write failing custom-word tests**

Tests must include:

~~~swift
func testAddWordTrimsWhitespaceAndNewlines()
func testAddWordRejectsEmptyInput()
func testAddWordRejectsCaseInsensitiveDuplicate()
func testAddWordRejectsMoreThanFiftyCharacters()
func testLegacyWordDecodesWithoutCategory()
func testInvalidLegacyEntriesRemainStoredButAreExcludedFromGameplay()
func testTaggedWordReturnsItsBuiltInCategoryForHints()
~~~

Assert exact result values:

~~~swift
XCTAssertEqual(service.addWord("   \n", difficulty: .kids), .empty)
XCTAssertEqual(service.addWord(String(repeating: "A", count: 51), difficulty: .hard), .tooLong(maximum: 50))
~~~

- [ ] **Step 2: Run tests and verify RED**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/CustomWordServiceTests" -derivedDataPath /tmp/imposter-hunt-task3-red
~~~

Expected: compile/test failures because AddWordResult, injected defaults, and usableWords do not exist.

- [ ] **Step 3: Implement non-destructive custom-word validation**

Add:

~~~swift
enum AddWordResult: Equatable {
    case added(CustomWord)
    case empty
    case tooLong(maximum: Int)
    case duplicate
}
~~~

CustomWordService retains raw decoded storage and computes usableWords by trimming whitespaceAndNewlines, ignoring empty values, and keeping the first case-insensitive occurrence without saving the filtered array. addWord returns the typed result and saves only successful new values.

words(for:) and wordStrings(for:) read from usableWords. wordCount and hasWords reflect usableWords so invalid legacy values cannot enable My Words or Begin Game.

- [ ] **Step 4: Connect exact add errors and category tagging**

AddWordRow presents:

- Enter a word.
- Keep words to 50 characters or fewer.
- That word is already in My Words.

Use the existing built-in categories as optional tags. Preserve the existing local categoryId work. CustomWordRow displays the selected difficulty and category tag without displaying Unknown.

GameSettingsView adds a Manage Custom Words button that presents CustomWordsView in a sheet. Closing the sheet returns to the same game settings and player state.

- [ ] **Step 5: Verify custom words do not leak a synthetic hint**

Extend GameViewModelTests so:

- Tagged custom word maps only to its real built-in category.
- Untagged custom word produces selectedCategory == nil.
- imposterGetsHint may be true while RoleRevealView still suppresses the category section when selectedCategory is nil.

- [ ] **Step 6: Run focused and full tests**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/CustomWordServiceTests" -only-testing:"Find The ImposterTests/GameViewModelTests" -derivedDataPath /tmp/imposter-hunt-task3-green
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task3-full
~~~

Expected: all focused and full tests pass.

- [ ] **Step 7: Commit custom words**

Run:

~~~bash
git add "Find The Imposter/Models/CustomWord.swift" "Find The Imposter/Models/Difficulty.swift" "Find The Imposter/Services/CustomWordService.swift" "Find The Imposter/ViewModels/GameViewModel.swift" "Find The Imposter/Views/CustomWords/AddWordRow.swift" "Find The Imposter/Views/CustomWords/CustomWordRow.swift" "Find The Imposter/Views/CustomWords/CustomWordsView.swift" "Find The Imposter/Views/GameSetup/GameSettingsView.swift" "Find The Imposter/Views/GameSetup/CategoryPickerView.swift" "Find The ImposterTests/CustomWordServiceTests.swift" "Find The ImposterTests/GameViewModelTests.swift"
git commit -m "Harden custom words and category hints"
~~~

---

### Task 4: Curate and expand the built-in word bank

**Files:**
- Modify: Find The Imposter/Resources/WordData.json
- Modify: Find The Imposter/Utilities/Extensions/Color+Theme.swift
- Create: Find The ImposterTests/WordDataServiceTests.swift

**Interfaces:**
- Produces: category IDs creators, athletes, celebrities.
- Produces: exactly 23 categories and 2,070 built-in words.
- Consumes: Category.words dictionary keys kids, medium, hard.

- [ ] **Step 1: Write failing structural tests**

WordDataServiceTests loads WordData.json through WordDataService and asserts:

~~~swift
func testWordBankHasExpectedCategoryAndWordCounts() {
    let service = WordDataService()
    XCTAssertEqual(service.categories.count, 23)
    XCTAssertEqual(service.categories.reduce(0) { total, category in
        total + Difficulty.allCases.reduce(0) { $0 + category.words(for: $1).count }
    }, 2_070)
}

func testEveryDifficultyBucketHasThirtyNonEmptyUniqueEntries()
func testCategoryIdentifiersAreUnique()
func testPeopleCategoriesContainNinetyNamesWithoutCrossCategoryOverlap()
~~~

Normalize uniqueness with folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) after trimming whitespacesAndNewlines.

- [ ] **Step 2: Run tests and verify RED**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/WordDataServiceTests" -derivedDataPath /tmp/imposter-hunt-task4-red
~~~

Expected: failures report 20 categories and 1,800 words.

- [ ] **Step 3: Apply high-confidence one-for-one curation**

Apply the reviewed replacements and spelling corrections, including:

~~~text
sports/kids: Camping -> Dodgeball
movies/kids: Monsters Inc -> Monsters, Inc.
movies/hard: Schindlers List -> Schindler's List
movies/hard: 2001 A Space Odyssey -> 2001: A Space Odyssey
movies/hard: Oldboy -> Rear Window
professions/kids: Princess -> Gardener
professions/kids: Superhero -> Musician
professions/hard: Maitre D -> Maître d'
household/hard: Epergne -> Dehumidifier
household/hard: Girandole -> Induction Cooktop
household/hard: Escritoire -> Immersion Blender
nature/hard: St Elmos Fire -> St. Elmo's Fire
transportation/hard: Junk -> Funicular
transportation/hard: Droshky -> Snowcat
music/medium: Hi Hat -> Hi-Hat
music/hard: Hang Drum -> Handpan
technology/hard: FPGA -> Facial Recognition
technology/hard: ASIC -> Natural Language Processing
clothing/hard: Peignoir -> Fascinator
clothing/hard: Ghillie -> Ghillie Brogues
bodyparts/medium: Achilles -> Achilles Tendon
hobbies/medium: Wine Tasting -> Model Building
hobbies/hard: Wattle and Daub -> Whittling
emotions/hard: Nemesis -> Disillusionment
emotions/hard: Ineffable -> Trepidation
emotions/hard: Liminal -> Alienation
emotions/hard: Dark Night of Soul -> Dark Night of the Soul
emotions/hard: Empty Nest -> Empty Nest Syndrome
fairytales/hard: Egregore -> Baba Yaga
fairytales/hard: Thoughtform -> Rumpelstiltskin
superheroes/hard: Death -> Sinestro
superheroes/hard: Eternity -> Reverse-Flash
superheroes/hard: Infinity -> General Zod
superheroes/hard: Oblivion -> Silver Surfer
holidays/kids: Valentine Day -> Valentine's Day
holidays/kids: St Patrick Day -> St. Patrick's Day
holidays/kids: Mother Day -> Mother's Day
holidays/kids: Father Day -> Father's Day
holidays/medium: Day of Dead -> Day of the Dead
holidays/medium: Leap Year -> April Fools' Day
holidays/hard: Mid Autumn Festival -> Mid-Autumn Festival
~~~

Before applying the replacements, confirm every addition is absent from its target category/difficulty list. The structural test is the binding guard against a duplicate; do not substitute an unreviewed word.

- [ ] **Step 4: Add three complete people categories**

Append these exact JSON category objects to the categories array:

~~~json
[
{
  "id": "creators",
  "name": "Streamers & Creators",
  "icon": "play.rectangle.fill",
  "words": {
    "kids": [
      "MrBeast", "Ryan Kaji", "Like Nastya", "DanTDM", "TommyInnit",
      "Aphmau", "PrestonPlayz", "Unspeakable", "Stampylonghead", "LDShadowLady",
      "ItsFunneh", "KreekCraft", "Thinknoodles", "SSundee", "Mark Rober",
      "Zach King", "Rebecca Zamolo", "Jordan Matter", "Moriah Elizabeth", "Rosanna Pansino",
      "Brent Rivera", "Ben Azelart", "Lexi Rivera", "Alan Chikin Chow", "TheOdd1sOut",
      "Jaiden Animations", "Khaby Lame", "LaurenZside", "CoryxKenshin", "Charli D'Amelio"
    ],
    "medium": [
      "Markiplier", "Jacksepticeye", "Ninja", "Pokimane", "Valkyrae",
      "Sykkuno", "Ludwig Ahgren", "LazarBeam", "Typical Gamer", "VanossGaming",
      "CaptainSparklez", "Grian", "Mumbo Jumbo", "MatPat", "Rhett McLaughlin",
      "Link Neal", "Safiya Nygaard", "Casey Neistat", "Marques Brownlee", "iJustine",
      "Emma Chamberlain", "Lilly Singh", "Liza Koshy", "Michelle Phan", "NikkieTutorials",
      "Bretman Rock", "Sean Evans", "KallMeKris", "Nick DiGiovanni", "GoodTimesWithScar"
    ],
    "hard": [
      "Hank Green", "Ryan Higa", "Anthony Padilla", "Ian Hecox", "Grace Helbig",
      "Hannah Hart", "Tyler Oakley", "Freddie Wong", "Tom Scott", "Michael Stevens (Vsauce)",
      "Derek Muller (Veritasium)", "Destin Sandlin (Smarter Every Day)", "Simone Giertz", "Colin Furze", "Michael Reeves",
      "NileRed", "Ali Abdaal", "Peter McKinnon", "Matt D'Avella", "Andrew Rea (Binging with Babish)",
      "Joshua Weissman", "Maangchi", "Ann Reardon", "Cristine Rotenberg (Simply Nailogical)", "Cassey Ho",
      "Adriene Mishler", "Kurtis Conner", "Danny Gonzalez", "Dan Howell", "iHasCupquake"
    ]
  }
},
{
  "id": "athletes",
  "name": "Athletes",
  "icon": "medal.fill",
  "words": {
    "kids": [
      "Lionel Messi", "Cristiano Ronaldo", "LeBron James", "Michael Jordan", "Stephen Curry",
      "Serena Williams", "Tiger Woods", "Simone Biles", "Usain Bolt", "Tom Brady",
      "Patrick Mahomes", "Shohei Ohtani", "Sidney Crosby", "Connor McDavid", "Wayne Gretzky",
      "Rafael Nadal", "Roger Federer", "Lewis Hamilton", "Max Verstappen", "Michael Phelps",
      "Shaquille O'Neal", "Caitlin Clark", "Naomi Osaka", "Coco Gauff", "Kylian Mbappé",
      "Erling Haaland", "Luka Dončić", "Giannis Antetokounmpo", "Tony Hawk", "Alex Morgan"
    ],
    "medium": [
      "David Beckham", "Pelé", "Marta Vieira da Silva", "Mohamed Salah", "Sachin Tendulkar",
      "Virat Kohli", "MS Dhoni", "Magic Johnson", "Larry Bird", "Kareem Abdul-Jabbar",
      "Dirk Nowitzki", "Steve Nash", "Sue Bird", "Diana Taurasi", "Candace Parker",
      "Babe Ruth", "Jackie Robinson", "Derek Jeter", "Ichiro Suzuki", "Mario Lemieux",
      "Bobby Orr", "Gordie Howe", "Steffi Graf", "Andy Murray", "Iga Świątek",
      "Katie Ledecky", "Nadia Comăneci", "Ayrton Senna", "Rory McIlroy", "George Foreman"
    ],
    "hard": [
      "Johan Cruyff", "Franz Beckenbauer", "Eusébio", "Ferenc Puskás", "Paolo Maldini",
      "Christine Sinclair", "Homare Sawa", "Don Bradman", "Viv Richards", "Wasim Akram",
      "Muttiah Muralitharan", "Jonah Lomu", "Dan Carter", "Eliud Kipchoge", "Florence Griffith Joyner",
      "Mark Spitz", "Ian Thorpe", "Kohei Uchimura", "Yuzuru Hanyu", "Mikaela Shiffrin",
      "Rod Laver", "Björn Borg", "Chris Evert", "Annika Sörenstam", "Seve Ballesteros",
      "Roberto Clemente", "Willie Mays", "Hakeem Olajuwon", "Maurice Richard", "Sugar Ray Leonard"
    ]
  }
},
{
  "id": "celebrities",
  "name": "Celebrities",
  "icon": "star.fill",
  "words": {
    "kids": [
      "Taylor Swift", "Beyoncé", "Rihanna", "Adele", "Ariana Grande",
      "Selena Gomez", "Lady Gaga", "Bruno Mars", "Ed Sheeran", "Justin Bieber",
      "Billie Eilish", "The Weeknd", "Katy Perry", "Miley Cyrus", "Harry Styles",
      "Dua Lipa", "Shakira", "Zendaya", "Jenna Ortega", "Tom Hanks",
      "Leonardo DiCaprio", "Ryan Reynolds", "Keanu Reeves", "Margot Robbie", "Chris Hemsworth",
      "Robert Downey Jr.", "Emma Watson", "Daniel Radcliffe", "Jim Carrey", "Gordon Ramsay"
    ],
    "medium": [
      "Jennifer Lopez", "Mariah Carey", "Celine Dion", "Dolly Parton", "Stevie Wonder",
      "Alicia Keys", "John Legend", "Kelly Clarkson", "Christina Aguilera", "Gwen Stefani",
      "P!nk", "Shania Twain", "Usher", "Olivia Rodrigo", "Michael Bublé",
      "Anne Hathaway", "Meryl Streep", "Julia Roberts", "Reese Witherspoon", "Nicole Kidman",
      "Denzel Washington", "Samuel L. Jackson", "Morgan Freeman", "Harrison Ford", "Sandra Bullock",
      "Oprah Winfrey", "Steve Harvey", "Simon Cowell", "David Attenborough", "Jennifer Aniston"
    ],
    "hard": [
      "Julie Andrews", "Audrey Hepburn", "Cary Grant", "Sidney Poitier", "Ingrid Bergman",
      "Katharine Hepburn", "James Stewart", "Angela Lansbury", "Maggie Smith", "Helen Mirren",
      "Judi Dench", "Anthony Hopkins", "Ian McKellen", "Patrick Stewart", "Viola Davis",
      "Michelle Yeoh", "Lupita Nyong'o", "Shah Rukh Khan", "Amitabh Bachchan", "Aishwarya Rai Bachchan",
      "Penélope Cruz", "Javier Bardem", "Antonio Banderas", "Salma Hayek", "Aretha Franklin",
      "Whitney Houston", "Diana Ross", "Cher", "Elton John", "Paul McCartney"
    ]
  }
}
]
~~~

Append the three objects from this array, without the outer array brackets, to WordData.json's existing categories array. Preserve accents and punctuation. Recheck:

- No person appears twice across the three new categories.
- No political figure appears.
- Creator labels are unambiguous handles or full names.
- Athletes cover multiple sports, eras, genders, and regions.
- Celebrities are not primarily athletes or internet creators.

Add stable theme colors:

~~~swift
case "creators": return .cyan
case "athletes": return .green
case "celebrities": return .pink
~~~

- [ ] **Step 5: Validate JSON and verify GREEN**

Run:

~~~bash
jq empty "Find The Imposter/Resources/WordData.json"
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterTests/WordDataServiceTests" -derivedDataPath /tmp/imposter-hunt-task4-green
~~~

Expected: jq exits 0; the tests confirm 23 categories, 2,070 entries, 30 entries per bucket, and unique people names.

- [ ] **Step 6: Commit word-bank changes**

Run:

~~~bash
git add "Find The Imposter/Resources/WordData.json" "Find The Imposter/Utilities/Extensions/Color+Theme.swift" "Find The ImposterTests/WordDataServiceTests.swift"
git commit -m "Curate and expand the word bank"
~~~

---

### Task 5: Accessible role reveal, cancellation, and privacy

**Files:**
- Modify: Find The Imposter/ContentView.swift
- Create: Find The Imposter/Views/Home/PrivacyPolicyView.swift
- Modify: Find The Imposter/Views/Home/SettingsView.swift
- Modify: Find The Imposter/Views/RoleReveal/RoleRevealContainerView.swift
- Modify: Find The Imposter/Views/RoleReveal/PassPhoneView.swift
- Modify: Find The Imposter/Views/RoleReveal/FlippableCardView.swift
- Modify: Find The Imposter/Views/RoleReveal/RoleRevealView.swift
- Modify: Find The Imposter/Views/RoleReveal/RoleCardView.swift
- Modify: Find The Imposter/Views/GameSetup/GameSettingsView.swift
- Modify: Find The Imposter/Views/GameSetup/CategoryPickerView.swift
- Modify: Find The Imposter/Views/GameSetup/DifficultyPickerView.swift
- Modify: Find The ImposterUITests/ImposterHuntUITests.swift

**Interfaces:**
- Consumes: GameViewModel.cancelRoleReveal().
- Produces: accessibility identifiers reveal-role, back-to-settings, privacy-policy.
- Produces: local PrivacyPolicyView and inactive-scene privacy shield.

- [ ] **Step 1: Write failing UI tests**

Add helpers that launch the app, complete onboarding when requested, enter Alex, Blair, and Casey, and reach Game Settings.

Add:

~~~swift
func testDuplicatePlayerNamesCannotContinue()
func testRoleCanBeRevealedWithButton()
func testRoleRevealCanReturnToSettings()
func testSettingsExposeCustomWordsAndPrivacyPolicy()
~~~

The reveal test must locate app.buttons["reveal-role"] and not perform a drag.

- [ ] **Step 2: Run the UI tests and verify RED**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterUITests/ImposterHuntUITests" -derivedDataPath /tmp/imposter-hunt-task5-red
~~~

Expected: tests fail because the identifiers, reveal button, cancellation UI, and privacy policy screen do not exist.

- [ ] **Step 3: Make the card accessible without exposing secrets**

FlippableCardView adds an on-tap reveal route and marks faces:

~~~swift
back
    .accessibilityHidden(effectiveRotation >= 90)

front
    .accessibilityHidden(effectiveRotation < 90)
~~~

RoleRevealView adds a visible Reveal Role PrimaryButton before flipping:

~~~swift
PrimaryButton("Reveal Role", icon: "eye.fill") {
    viewModel.flipCard()
}
.accessibilityIdentifier("reveal-role")
~~~

Use AccessibilityFocusState to focus a single role summary after reveal. Do not expose the secret word before reveal through labels, values, hints, or hidden views.

- [ ] **Step 4: Add Back to Settings with confirmation**

RoleRevealContainerView owns confirmation state. PassPhoneView and RoleRevealView expose the same back action. If no role has been revealed, return immediately; otherwise show:

~~~text
Title: Return to Settings?
Message: Revealed roles will be cleared and reassigned when you begin again.
Confirm: Return to Settings
Cancel: Keep Playing
~~~

The confirm action calls cancelRoleReveal().

- [ ] **Step 5: Add privacy screen and inactive-scene shield**

PrivacyPolicyView states the exact local-data behavior in the design spec and exposes privacy-policy as its accessibility identifier.

SettingsView adds a NavigationLink named Privacy Policy and derives version text:

~~~swift
private var versionText: String {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "2"
    return "Version \(version) (\(build))"
}
~~~

ContentView observes scenePhase and overlays an opaque dark screen with the Imposter Hunt name whenever scenePhase != .active.

- [ ] **Step 6: Improve accessibility metadata**

- SettingsToggleRow uses accessibilityElement(children: .combine), accessibilityLabel(title), and accessibilityValue(isOn ? "On" : "Off").
- DifficultyChip and CategoryChip add .isSelected when selected.
- ImposterCountPicker labels decrement and increment buttons.
- Primary navigation buttons receive stable identifiers used by UI tests.

- [ ] **Step 7: Run UI and unit suites and verify GREEN**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -only-testing:"Find The ImposterUITests/ImposterHuntUITests" -derivedDataPath /tmp/imposter-hunt-task5-green
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task5-full
~~~

Expected: UI and full suites pass.

- [ ] **Step 8: Commit accessible reveal and privacy**

Run:

~~~bash
git add "Find The Imposter/ContentView.swift" "Find The Imposter/Views/Home/PrivacyPolicyView.swift" "Find The Imposter/Views/Home/SettingsView.swift" "Find The Imposter/Views/RoleReveal/RoleRevealContainerView.swift" "Find The Imposter/Views/RoleReveal/PassPhoneView.swift" "Find The Imposter/Views/RoleReveal/FlippableCardView.swift" "Find The Imposter/Views/RoleReveal/RoleRevealView.swift" "Find The Imposter/Views/RoleReveal/RoleCardView.swift" "Find The Imposter/Views/GameSetup/CategoryPickerView.swift" "Find The Imposter/Views/GameSetup/DifficultyPickerView.swift" "Find The Imposter/Views/GameSetup/GameSettingsView.swift" "Find The ImposterUITests/ImposterHuntUITests.swift"
git commit -m "Make role reveal accessible and private"
~~~

---

### Task 6: Reduce Motion, scalable layout, and copy polish

**Files:**
- Modify: Find The Imposter/Utilities/Extensions/View+Animations.swift
- Modify: Find The Imposter/Views/Components/AnimatedBackground.swift
- Modify: Find The Imposter/Views/Home/HomeView.swift
- Modify: Find The Imposter/Views/RoleReveal/PassPhoneView.swift
- Modify: Find The Imposter/Views/RoleReveal/CardBackView.swift
- Modify: Find The Imposter/Views/RoleReveal/FlippableCardView.swift
- Modify: Find The Imposter/Views/RoleReveal/RoleRevealView.swift
- Modify: Find The Imposter/Views/RoleReveal/RoleCardView.swift
- Modify: Find The Imposter/Views/Playing/StartGameView.swift
- Modify: Find The Imposter/Views/EndGame/EndGameView.swift
- Modify: Find The Imposter/Views/EndGame/ImposterRevealView.swift
- Modify: Find The Imposter/Views/EndGame/WordRevealView.swift
- Modify: Find The Imposter/Views/Onboarding/OnboardingView.swift
- Modify: Find The Imposter/Views/Onboarding/OnboardingPageView.swift

**Interfaces:**
- Consumes: Environment accessibilityReduceMotion.
- Produces: no continuous or celebratory motion when Reduce Motion is enabled.
- Produces: consistent Imposter Hunt product copy.

- [ ] **Step 1: Add Reduce Motion guards**

Each view with continuous animation reads:

~~~swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
~~~

For onAppear animations:

~~~swift
guard !reduceMotion else {
    setFinalVisualState()
    return
}
~~~

AnimatedBackground keeps animationPhase at zero. CardBackView stops rotation and shimmer. PassPhoneView and HomeView stop pulsing loops. WordRevealView does not create confetti. ImposterRevealView omits shake and glow loops. EndGameView and StartGameView immediately set final opacity/scale values.

FlippableCardView changes directly between 0 and 180 degrees without spring animation when reduceMotion is true.

- [ ] **Step 2: Make role and word content scale safely**

RoleCardView replaces fixed display sizes with @ScaledMetric values capped to preserve the card:

~~~swift
@ScaledMetric(relativeTo: .largeTitle) private var roleIconSize: CGFloat = 70
@ScaledMetric(relativeTo: .title) private var secretWordSize: CGFloat = 32
~~~

Keep lineLimit(2), minimumScaleFactor(0.5), and multiline alignment for secret words. Ensure the card content can scroll vertically at accessibility text sizes while keeping the role summary first.

HomeView, StartGameView, and onboarding pages must keep their primary buttons inside safe areas on the smallest available iPhone simulator.

- [ ] **Step 3: Normalize branding and copy**

Replace user-facing product-name occurrences of Find The Imposter with Imposter Hunt. Do not rename the Xcode project, target, source folder, module, or bundle identifier.

Verify singular/plural strings use:

~~~swift
"\(count) word\(count == 1 ? "" : "s")"
~~~

Update tutorial wording so the onlyIfStarts description matches the repaired behavior.

- [ ] **Step 4: Build and manually inspect motion modes**

Run:

~~~bash
xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task6
~~~

Expected: BUILD SUCCEEDED.

In Simulator, verify normal motion remains and Reduce Motion removes continuous loops, 3D card motion, shake, and confetti without hiding content or controls.

- [ ] **Step 5: Run the complete test suite**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-task6-tests
~~~

Expected: all unit and UI tests pass.

- [ ] **Step 6: Commit motion and polish**

Run:

~~~bash
git add "Find The Imposter/Utilities/Extensions/View+Animations.swift" "Find The Imposter/Views/Components/AnimatedBackground.swift" "Find The Imposter/Views/Home/HomeView.swift" "Find The Imposter/Views/RoleReveal/PassPhoneView.swift" "Find The Imposter/Views/RoleReveal/CardBackView.swift" "Find The Imposter/Views/RoleReveal/FlippableCardView.swift" "Find The Imposter/Views/RoleReveal/RoleRevealView.swift" "Find The Imposter/Views/RoleReveal/RoleCardView.swift" "Find The Imposter/Views/Playing/StartGameView.swift" "Find The Imposter/Views/EndGame/EndGameView.swift" "Find The Imposter/Views/EndGame/ImposterRevealView.swift" "Find The Imposter/Views/EndGame/WordRevealView.swift" "Find The Imposter/Views/Onboarding/OnboardingView.swift" "Find The Imposter/Views/Onboarding/OnboardingPageView.swift"
git commit -m "Respect accessibility motion and text settings"
~~~

---

### Task 7: App Store documentation and repository accuracy

**Files:**
- Modify: README.md
- Modify: WARP.md
- Modify: CLAUDE.md
- Create: AppStore/Submission.md
- Create: AppStore/PrivacyPolicy.md

**Interfaces:**
- Consumes: final app behavior and exact tests from Tasks 1 through 6.
- Produces: copy ready to paste into App Store Connect and the owner's website.

- [ ] **Step 1: Write the publishable privacy policy**

AppStore/PrivacyPolicy.md must state:

- Effective date July 16, 2026.
- No accounts and no collected, transmitted, sold, shared, or tracked personal data.
- Player names, preferences, and custom words are stored locally with UserDefaults.
- Deleting the app removes locally stored data.
- Privacy questions use the developer contact on the App Store listing.

Do not invent an email address or URL.

- [ ] **Step 2: Write App Store submission copy**

AppStore/Submission.md includes:

- Name: Imposter Hunt.
- Primary category: Games.
- Version: 1.0, build 2.
- A concise subtitle within 30 characters.
- Promotional text within 170 characters.
- Description within 4,000 characters.
- Keywords within 100 comma-separated characters.
- Privacy label: Data Not Collected.
- Encryption: no non-exempt encryption.
- Age-rating guidance based on the final family-safe static word bank.
- Content-rights guidance explaining that public-figure names appear as static clue targets without images, biography, endorsement, or runtime third-party content.
- Review notes explaining the local pass-the-phone flow and that no login or network is required.
- The exact automated and manual verification commands actually run; do not claim future checks.
- Owner-controlled fields: privacy-policy URL and support URL.

- [ ] **Step 3: Correct stale repository guidance**

README.md and WARP.md must say:

- iOS 17.0 minimum.
- Xcode 26 or later for current App Store submission requirements.
- Use the shared Find The Imposter scheme.
- Run the exact xcodebuild test and Release build commands from this plan.

CLAUDE.md updates CustomWord to include optional categoryId, documents injected defaults, shared tests, iPhone-only release scope, and the corrected starting-player rule.

- [ ] **Step 4: Validate documentation**

Run:

~~~bash
rg -n "iOS 18\\.5|Xcode 16\\.4|Version 1\\.0$|Find The Imposter" README.md WARP.md CLAUDE.md AppStore "Find The Imposter/Views"
git diff --check
~~~

Expected: no stale toolchain claims, no hardcoded settings version, and no whitespace errors. Xcode target/module references may still use Find The Imposter where technically required.

- [ ] **Step 5: Commit submission documentation**

Run:

~~~bash
git add README.md WARP.md CLAUDE.md AppStore/Submission.md AppStore/PrivacyPolicy.md
git commit -m "Prepare App Store submission materials"
~~~

---

### Task 8: Full release verification and screenshots

**Files:**
- Create: AppStore/Screenshots/01-home.png
- Create: AppStore/Screenshots/02-game-settings.png
- Create: AppStore/Screenshots/03-role-reveal.png
- Modify: AppStore/Submission.md

**Interfaces:**
- Consumes: verified application and shared scheme from all earlier tasks.
- Produces: final evidence, three truthful simulator screenshots, and a push-ready branch.

- [ ] **Step 1: Run fresh automated verification**

Run:

~~~bash
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-final-tests-20260716
xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-release-20260716 CODE_SIGNING_ALLOWED=NO
xcodebuild analyze -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-analyze-20260716 CODE_SIGNING_ALLOWED=NO
xcodebuild archive -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -archivePath /tmp/imposter-hunt-final-archive-20260716.xcarchive
~~~

Expected: tests, Release build, and analyzer succeed. Archive succeeds when local signing is available; otherwise record the exact signing blocker without weakening other verification claims.

- [ ] **Step 2: Validate static release artifacts**

Run:

~~~bash
plutil -lint "Find The Imposter/PrivacyInfo.xcprivacy"
sips -g pixelWidth -g pixelHeight -g hasAlpha "Find The Imposter/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
jq empty "Find The Imposter/Resources/WordData.json"
git diff --check
~~~

Expected: manifest and JSON validate; icon is 1024 by 1024 with hasAlpha: no; diff check is clean.

Inspect the Release app bundle:

~~~bash
find /tmp/imposter-hunt-final-release-20260716/Build/Products/Release-iphoneos/Find\ The\ Imposter.app -maxdepth 2 -type f -print
~~~

Expected: PrivacyInfo.xcprivacy is present; the three source-art PNG filenames are absent.

- [ ] **Step 3: Perform manual simulator QA**

Exercise and record:

- Cold first launch and all onboarding pages.
- Tutorial replay from Settings.
- Sound and haptic toggles.
- Privacy Policy and Custom Words.
- Empty, duplicate, overlong, tagged, and untagged custom words.
- Three-player and twelve-player setup.
- Blank, duplicate, and overlong player names.
- Every hint mode.
- Role reveal by tap and swipe.
- Back to Settings before and after reveal.
- Complete role flow, start player announcement, end-game reveals, play again, and change settings.
- Background/foreground privacy shield during secret screens.
- Accessibility tree before and after reveal.
- Reduce Motion enabled.
- An accessibility text size.

- [ ] **Step 4: Capture verified screenshots**

Use an available large iPhone simulator in portrait orientation. Reset or seed only non-sensitive local demo data. Capture:

- Home screen with no overlays.
- Game Settings showing category breadth.
- A role-reveal card that does not expose user-private data.

Save exact PNGs as the three paths listed above. Confirm dimensions satisfy the current App Store Connect iPhone screenshot specification before committing them.

- [ ] **Step 5: Update verification evidence**

Replace the verification section in AppStore/Submission.md with only the commands and outcomes actually observed in Steps 1 through 4. Record archive/signing limitations exactly.

- [ ] **Step 6: Review final diff and commit screenshots**

Run:

~~~bash
git status --short
git diff --stat main...HEAD
git diff --check
git log --oneline --decorate main..HEAD
~~~

Review every changed file for scope, secrets, unrelated cleanup, and lost user changes.

Then:

~~~bash
git add AppStore/Screenshots/01-home.png AppStore/Screenshots/02-game-settings.png AppStore/Screenshots/03-role-reveal.png AppStore/Submission.md
git commit -m "Add verified App Store screenshots"
~~~

Expected: clean worktree after the commit, all implementation commits present, and no push performed by this task.

---

## Final branch review and delivery

After all tasks pass their task-scoped spec and quality reviews:

1. Generate a full branch review package from merge-base main to HEAD.
2. Dispatch the final whole-branch reviewer.
3. Fix and re-review every Critical or Important finding.
4. Re-run the full verification commands from Task 8 after the final fix.
5. Push prepare-app-store to origin, updating PR #1, using the user's explicit authorization.
6. Inspect PR #1 checks, diff, and review threads after the push.
7. Present the exact tested commit range, checks, and remaining external App Store fields.
8. Request merge-specific confirmation before merging PR #1 into main.
