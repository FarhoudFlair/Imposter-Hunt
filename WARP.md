# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
Imposter Hunt is an iPhone-only, portrait iOS application built with SwiftUI. It supports iOS 17.0 or later and requires Xcode 26 or later for current App Store submission requirements. Use the shared Find The Imposter scheme. The technical Xcode project and shared scheme remain named `Find The Imposter`.

## Build System
This project uses Xcode's native build system with the following configuration:
- **Development Team**: 23TQMQNW28
- **Bundle Identifier**: FarhoudTalebi.Find-The-Imposter
- **Deployment Target**: iOS 17.0
- **Supported Devices**: iPhone only, portrait orientation

## Common Commands

### Testing and Release Building
Use the shared `Find The Imposter` scheme for command-line and Xcode operations.

```bash
# Run the full unit and UI test suite
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-final-tests-20260716

# Build the unsigned Release configuration
xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-release-20260716 CODE_SIGNING_ALLOWED=NO
```

### Opening in Xcode
```bash
open "Find The Imposter.xcodeproj"
```

## Architecture

### Project Structure
The project uses a flat structure with SwiftUI views:
- **Find The Imposter/** - Main source directory containing all Swift files
- **Find The Imposter.xcodeproj/** - Xcode project configuration
- **Assets.xcassets/** - Image and color assets

### Key Components
- **Find_The_ImposterApp.swift** - App entry point using the `@main` attribute
- **ContentView.swift** - Root SwiftUI view with SwiftUI Previews enabled

### SwiftUI Architecture
This project uses SwiftUI's declarative UI framework:
- Views are defined as structs conforming to the `View` protocol
- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`) for rapid UI iteration
- Uses `#Preview` macro for preview definitions

### Build Configuration
- **Debug**: Includes debug symbols, optimization level 0, testability enabled
- **Release**: Whole module optimization, stripped debug info for distribution
- Auto-generated Info.plist (`GENERATE_INFOPLIST_FILE = YES`)
- Scene-based UI lifecycle

## Development Notes

### Code Signing
The project uses Automatic code signing with development team ID 23TQMQNW28. When working on this project, you may need to update the development team to match your Apple Developer account.

### Supported Orientations
- **iPhone**: Portrait only
- **iPad**: Not supported in the App Store release

### Swift Compilation
- Swift 5.0 language version
- Generates Swift asset symbol extensions for type-safe asset access
- Whole module optimization in Release builds