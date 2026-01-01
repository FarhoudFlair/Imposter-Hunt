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
- **Services:** `AudioService`, `HapticsService`, `WordDataService` - instantiated within GameViewModel
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
| `GameSettings.swift` | Persisted settings with in-memory backing + HintMode enum |
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
