# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
"Find The Imposter" is an iOS application built with SwiftUI targeting iOS 18.5+. The project uses Xcode 16.4 and Swift 5.0.

## Build System
This project uses Xcode's native build system with the following configuration:
- **Development Team**: 23TQMQNW28
- **Bundle Identifier**: FarhoudTalebi.Find-The-Imposter
- **Deployment Target**: iOS 18.5
- **Supported Devices**: iPhone and iPad (Universal)

## Common Commands

### Building and Running
```bash
# Build the project
xcodebuild -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Debug build

# Build for release
xcodebuild -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release build

# Clean build folder
xcodebuild -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" clean
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
- **iPhone**: Portrait, Landscape Left, Landscape Right
- **iPad**: All orientations including upside down

### Swift Compilation
- Swift 5.0 language version
- Generates Swift asset symbol extensions for type-safe asset access
- Whole module optimization in Release builds
