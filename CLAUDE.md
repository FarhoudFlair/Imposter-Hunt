# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build for iOS Simulator
xcodebuild -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 16" build

# Convert audio files to iOS-optimal format
afconvert input.wav -o output.m4a -f m4af -d aac -b 128000
```

## Architecture

### MVVM with Environment Injection
- **Single ViewModel:** `GameViewModel` manages all game state, injected via `.environment()` at app root
- **Services:** `AudioService`, `HapticsService`, `WordDataService`, `CustomWordService` - instantiated within GameViewModel
- **Game phases:** Controlled by `GamePhase` enum, navigation handled in `ContentView`

### Critical: SwiftUI Reactivity with UserDefaults
`GameSettings` uses **in-memory backing storage** with UserDefaults sync. `@Observable` only tracks stored property mutations - computed properties via UserDefaults serialization don't trigger view updates.

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
- `onlyIfStarts`: Only the randomly-chosen starting imposter gets hint

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
- `CustomWord` model: word + difficulty + UUID
- `CustomWordService`: UserDefaults persistence, in-memory backing (same pattern as GameSettings)
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
