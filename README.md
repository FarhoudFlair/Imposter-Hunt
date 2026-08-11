# Imposter Hunt

An iPhone-only iOS game built with SwiftUI where players must find the imposter among them.

## Requirements

- iOS 17.0 or later
- Xcode 26 or later for current App Store submission requirements
- Swift 5.0
- iPhone only in portrait orientation

## Building and Testing

Open `Find The Imposter.xcodeproj` and use the shared `Find The Imposter` scheme.

```bash
# Run the full unit and UI test suite
xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-final-tests-20260716

# Build the unsigned Release configuration
xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-release-20260716 CODE_SIGNING_ALLOWED=NO
```

## Project Structure

- **Find The Imposter/** - Main source files
- **Assets.xcassets/** - App icons and images
- Built with SwiftUI using declarative UI patterns

## Development

The app uses SwiftUI Previews for rapid iteration. Use the `#Preview` macro to preview UI components in Xcode.

## License

Copyright © 2025 Farhoud Talebi. All rights reserved.
