# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Run the full unit and UI test suite with the shared scheme
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-final-tests-20260716

# Build the unsigned Release configuration
xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-release-20260716 CODE_SIGNING_ALLOWED=NO
# Convert audio files to iOS-optimal format
afconvert input.wav -o output.m4a -f m4af -d aac -b 128000
```

## Architecture

### Release Scope and Shared Tests
- The product name is Imposter Hunt. Keep the technical project, module, and shared scheme names as `Find The Imposter`.
- The App Store release supports iOS 17.0 or later on iPhone only in portrait orientation. Do not add iPad or landscape release support.
- The shared `Find The Imposter` scheme includes the app target, the `Find The ImposterTests` unit-test target, and the `Find The ImposterUITests` UI-test target. Use the shared scheme for all test and Release builds.
- Shared unit and UI tests exercise injected UserDefaults defaults, CustomWord optional categoryId handling, and the corrected uniform starting-player selection rule.

### MVVM with Environment Injection
- **Single ViewModel:** `GameViewModel` manages all game state and is injected via `.environment()` at the app root
- **Dependencies:** The `GameViewModel` initializer accepts `GameSettings`, `WordDataService`, `AudioService`, `HapticsService`, and `CustomWordService`; production uses their default instances
- **Game phases:** Controlled by `GamePhase` enum, navigation handled in `ContentView`

`GameSettings` and `CustomWordService` use **in-memory backing storage** with UserDefaults sync. Each initializer accepts `defaults: UserDefaults = .standard`; tests inject an isolated suite-specific `UserDefaults` instance. `@Observable` only tracks stored property mutations, so computed properties that serialize directly through UserDefaults do not trigger view updates.

```swift
// CORRECT pattern used in this codebase:
private var _selectedDifficulties: Set<Difficulty>
var selectedDifficulties: Set<Difficulty> {
    get { _selectedDifficulties }
    set {
        _selectedDifficulties = newValue  // Triggers @Observable
        saveDifficulties(newValue)         // Persists to UserDefaults
    }
}
```

### Key Files
| File | Purpose |
|------|---------|
| `GameViewModel.swift` | Central state: players, roles, word selection, phase transitions |
| `GameSettings.swift` | Persisted settings with in-memory backing + HintMode enum + hasSeenOnboarding |
| `CustomWordService.swift` | User-created words with UserDefaults persistence |
| `FlippableCardView.swift` | Gesture-controlled 3D card flip animation |
| `WordDataService.swift` | Loads `WordData.json`, random word selection by category/difficulty |

### Game Flow
Home → Player Setup (3-12 names) → Game Settings → Role Reveal (pass phone) → Start Game → End Game (reveal imposters, then word)

### Imposter Hint Modes
```swift
enum HintMode { case off, always, onlyIfStarts }
```
- `off`: Imposters never see category
- `always`: All imposters see category hint
- `onlyIfStarts`: The starting player is chosen randomly from all players. The player sees a hint only when that randomly chosen player is an imposter.

### Card Flip Animation
`FlippableCardView` uses continuous gesture tracking:
- `effectiveRotation = rotation + abs(dragTranslation) * sensitivity`
- Commits flip when past 90° threshold
- Uses `rotation3DEffect` on y-axis

### Data Models

#### Category Struct
`Category` uses a **dictionary** for words, NOT separate properties:
```swift
struct Category: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let icon: String
    let words: [String: [String]]  // difficulty key -> word array
}

// Creating a Category:
Category(id: "custom", name: "My Words", icon: "heart", words: [:])

// Accessing words:
category.words(for: .medium)  // Returns [String]
```

#### Custom Words System
- `CustomWord` model: word + difficulty + optional `categoryId` + UUID. A missing category means the imposter receives no category hint for that word.
- `CustomWordService`: UserDefaults persistence with injected defaults and in-memory backing (same pattern as `GameSettings`)
- Custom category uses special ID `"custom"` in `CategoryPickerView` and `GameViewModel`
- Words are mixed into the general word pool when "My Words" category is selected

### Onboarding System
- `hasSeenOnboarding` in `GameSettings` (UserDefaults persisted)
- `OnboardingView` presented via `.fullScreenCover` in `ContentView`
- Reset via Settings → "Show Tutorial Again"

### View Components Pattern
Reusable UI elements in `Views/Components/`:
- `PrimaryButton`, `SecondaryButton` - Gradient buttons with bounce animation
- `AnimatedBackground` - Floating gradient orbs
- `BouncyModifier` - `.bouncyEntrance()`, `.staggeredAnimation()`, `.slideUp()` modifiers
