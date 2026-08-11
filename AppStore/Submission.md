# Imposter Hunt - App Store Connect Submission

**App Name:** Imposter Hunt
**Primary Category:** Games
**Version:** 1.0
**Build:** 2

## Subtitle (30 characters max)
Party word game for friends

## Promotional Text (170 characters max)
Hunt the imposter using a secret word. Pass the phone to reveal roles, then guess who knows it. Fully local and offline. No accounts or internet required.

## Description (4000 characters max)
Imposter Hunt is a fast, fun, pass-the-phone party game for 3-12 players on a single iPhone.

One player secretly receives a word while the others become imposters who must bluff their way through. After roles are revealed privately, everyone tries to spot who knows the secret word. Three hint modes, custom words, and 23 themed categories keep every round fresh.

**How to play**
- Enter 3-12 player names
- Choose a difficulty and one or more categories
- Pass the phone around for private role reveals
- Imposters try to blend in while the word holder drops clues
- Reveal the imposters, then the word

**Features**
- 23 categories with 2,070 curated, family-safe words
- Add your own custom words (local only)
- Three imposter hint modes including "only the starting player"
- Accessible with VoiceOver, Reduce Motion support, and Dynamic Type
- Privacy shield when app is backgrounded
- iPhone portrait only, iOS 17.0 and later

No login, no network, no ads, no tracking. Everything stays on your device. Delete the app to remove all local data.

Perfect for road trips, parties, and game nights.

## Keywords (100 characters max, comma-separated)
imposter,party,word,game,secret,guess,pass phone,friends,local,offline

## Privacy
- Privacy Label: Data Not Collected
- No non-exempt encryption

## Age Rating Guidance
4+. The app uses only a static, family-safe word bank (animals, food & drinks, sports, movies & TV, countries, jobs, emotions, objects, and public-figure name lists for Streamers & Creators, Athletes, and Celebrities). All content is suitable for a general audience with no violence, mature themes, or user-generated online content.

## Content Rights Guidance
Public-figure names appear exclusively as static text clue targets in the three added people categories. The app contains no images, logos, biographies, quotations, political figures, endorsement wording, likenesses, or runtime third-party content or API calls. All entries are pre-curated, bundled, and offline.

## Review Notes
This is a completely local, offline, single-device pass-the-phone multiplayer party game. Players add names on one iPhone and pass it around so each person can privately reveal their role (word holder or imposter). No login, accounts, network connection, or data transmission of any kind is required or performed at any time. All word selection uses the bundled static WordData.json plus optional UserDefaults-stored custom words created on the device. The app supports full accessibility (VoiceOver, Switch Control, larger text) and honors Reduce Motion. Back-to-Settings cancellation clears secret state safely. Background/foreground applies an opaque privacy shield over secret screens.

## Owner-Controlled Fields
- Privacy Policy URL: (owner to set in App Store Connect)
- Support URL: (owner to set in App Store Connect)

## Verified Evidence (Tasks 1-6 only; Task 8 pending)
- Xcode 26.6 used for all builds and tests.
- Simulator: iPhone 17 Pro, iOS 26.5.
- Minimum deployment: iOS 17.0.
- Device support: iPhone-only, portrait orientation.
- Scheme: shared "Find The Imposter" (includes app + unit + UI test targets).
- Marketing version 1.0, build number 2.
- Automated verification performed:
  - Task 1: xcodebuild -list; xcodebuild test (ProjectConfigurationTests + UI home launch).
  - Task 2: targeted unit tests for validation, injected defaults, starting player, cancellation (red then green).
  - Task 5: xcodebuild test only UI tests; full suite (post-fix UI class passed 5/5).
  - Task 6: xcodebuild build -configuration Debug succeeded; full xcodebuild test suite after initial Task 6 commit succeeded.
- All observed results: BUILD SUCCEEDED and tests passed where executed.
- No claims made for release build/analyze/archive, manual QA, or screenshots (those are Task 8).

Product name "Imposter Hunt" used for user-facing copy. Technical project, target, module, and scheme names remain "Find The Imposter" where required by Xcode.