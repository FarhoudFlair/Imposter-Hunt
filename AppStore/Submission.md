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

One player is secretly the imposter. Everyone else knows the secret word and must spot who is bluffing. After roles are revealed privately, the group debates and votes. Three hint modes, custom words, and 23 themed categories keep every round fresh.

How to play
- Enter 3-12 player names
- Choose a difficulty and one or more categories
- Pass the phone around for private role reveals
- The word holders drop clues while the imposter tries to blend in
- Reveal the imposter, then the word

Features
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

## Verified Evidence (Task 8)
Environment:
- Xcode 26.6 (Build 17F113)
- Simulator tests: iPhone 17 Pro, iOS 26.5
- Screenshot device: iPhone 17 Pro Max (UDID 05BB30BD-1DA7-4BFF-B7C1-B93AC86E2785), portrait, 1320x2868
- Minimum deployment: iOS 17.0
- Device support: iPhone-only, portrait orientation
- Scheme: shared "Find The Imposter" (app + unit + UI test targets)
- Marketing version 1.0, build number 2

Automated commands and outcomes:
1. `xcodebuild test -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5" -derivedDataPath /tmp/imposter-hunt-final-tests-clean-20260716`
   Outcome: ** TEST SUCCEEDED **; 31 tests passed, 0 failed (committed tree only).
2. `xcodebuild build -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-release-20260716 CODE_SIGNING_ALLOWED=NO`
   Outcome: ** BUILD SUCCEEDED **.
3. `xcodebuild analyze -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -derivedDataPath /tmp/imposter-hunt-final-analyze-20260716 CODE_SIGNING_ALLOWED=NO`
   Outcome: ** ANALYZE SUCCEEDED **.
4. `xcodebuild archive -project "Find The Imposter.xcodeproj" -scheme "Find The Imposter" -configuration Release -destination "generic/platform=iOS" -archivePath /tmp/imposter-hunt-final-archive-20260716.xcarchive`
   Outcome: ** ARCHIVE FAILED **. Exact blocker: `No profiles for 'FarhoudTalebi.Find-The-Imposter' were found: Xcode couldn't find any iOS App Development provisioning profiles matching 'FarhoudTalebi.Find-The-Imposter'. Automatic signing is disabled and unable to generate a profile.` Local signing/profile setup is required before archive succeeds; other verification claims are not weakened by this.
5. Static artifact checks:
   - `plutil -lint "Find The Imposter/PrivacyInfo.xcprivacy"` → OK
   - `sips -g pixelWidth -g pixelHeight -g hasAlpha "Find The Imposter/Assets.xcassets/AppIcon.appiconset/AppIcon.png"` → 1024x1024, hasAlpha: no
   - `jq empty "Find The Imposter/Resources/WordData.json"` → valid JSON
   - `git diff --check` → clean
6. Release app bundle inspection (`/tmp/imposter-hunt-final-release-20260716/Build/Products/Release-iphoneos/Find The Imposter.app`):
   - `PrivacyInfo.xcprivacy` present
   - `WordData.json` present
   - Source-art PNG filenames absent

Manual simulator QA (iPhone 17 Pro Max, Reduce Motion enabled for motion checks; also verified accessibility-extra-extra-extra-large content size on home):
- Home branding shows Imposter Hunt with Start Game and Settings; no overlays in screenshot 01.
- Game Settings shows all difficulties selected, 23 of 23 categories selected, custom words entry, Begin Game (screenshot 02).
- Role-reveal card for Alex in face-down state ("Swipe to Reveal" / Reveal Role) with no secret role or word exposed (screenshot 03).
- Existing automated UI coverage also exercised home launch, duplicate player-name block, role reveal by button, back-to-settings from role reveal, and Settings → Custom Words / Privacy Policy (ImposterHuntUITests, included in the 31-test suite above).
- Reduce Motion preference confirmed enabled (`ReduceMotionEnabled=1`); home remained usable under accessibility XXXL text size.

Screenshots committed:
- `AppStore/Screenshots/01-home.png` (1320x2868)
- `AppStore/Screenshots/02-game-settings.png` (1320x2868)
- `AppStore/Screenshots/03-role-reveal.png` (1320x2868)

Character limits (current copy):
- Subtitle: 27 / 30
- Promotional text: 154 / 170
- Description: 1077 / 4000
- Keywords: 70 / 100

Product name "Imposter Hunt" used for user-facing copy. Technical project, target, module, and scheme names remain "Find The Imposter" where required by Xcode.