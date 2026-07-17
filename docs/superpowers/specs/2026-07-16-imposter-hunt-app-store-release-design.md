# Imposter Hunt App Store Release Design

Date: 2026-07-16

## Objective

Prepare Imposter Hunt 1.0 for an iPhone App Store release by fixing confirmed gameplay defects, improving accessibility and privacy, curating the built-in word bank, adding three durable people categories, introducing automated tests, and packaging the local App Store submission materials.

The implementation must preserve the current visual identity and game flow. It must also preserve all user-owned uncommitted work already present on the prepare-app-store branch.

## Selected Approach

The selected approach is a release-complete, iPhone-only version 1.0:

- Target iPhone in portrait orientation with iOS 17.0 or later.
- Keep the current local, offline SwiftUI architecture and existing bundle identifier.
- Fix every confirmed release blocker and high-confidence quality issue found in the audit.
- Curate existing words conservatively through one-for-one replacements.
- Add Streamers & Creators, Athletes, and Celebrities as three complete categories.
- Add unit and UI regression coverage before merging.
- Do not add networking, analytics, advertising, accounts, monetization, multiplayer, or external dependencies.

The rejected alternatives were a native universal iPhone/iPad release, which would add a materially larger layout and orientation matrix, and a blocker-only patch, which would not meet the requested completeness bar.

## Release Configuration

The app will retain:

- Marketing version 1.0.
- Bundle identifier FarhoudTalebi.Find-The-Imposter.
- Display name Imposter Hunt.
- Minimum deployment target iOS 17.0.
- Automatic signing with the existing development team.
- No non-exempt encryption.
- Games App Store category.

The build number will become 2 so the release remains uploadable even if build 1 has already been associated with the App Store Connect record.

TARGETED_DEVICE_FAMILY will be iPhone only. The app will remain portrait-only on iPhone. The obsolete native-iPad orientation setting will be removed, eliminating the current universal-app orientation warning.

The opaque 1024-by-1024 App Store icon and PrivacyInfo.xcprivacy will be retained and verified in the built product. The three unused source-art PNG files under Resources will remain on disk but will be excluded from the app target and final bundle; no user files will be deleted.

## Gameplay Rules and State

### Starting player and hints

The starting player must be selected uniformly from all players, including imposters. This makes the default onlyIfStarts mode reachable.

Hint behavior remains:

- off: no imposter receives the category.
- always: every imposter receives the category when a meaningful category exists.
- onlyIfStarts: an imposter receives the category only when that imposter is selected to start.

An untagged custom word never displays My Words, Unknown, or another synthetic category as a hint.

Random selection will remain system-random in production. The starting-player selection entry point will accept a random-number generator internally so deterministic tests can verify the candidate set and result without flaky probability assertions.

### Setup validation

Player setup requires:

- Between 3 and 12 players.
- A non-empty name after trimming whitespace and newlines.
- No case-insensitive duplicate names.
- At most 24 user-perceived characters per name.

Game settings will distinguish these invalid states:

- No difficulty selected.
- No category selected.
- Selected categories and difficulties contain no usable words.

The Begin Game button remains disabled while any invalid state applies, and the visible message states the actual reason.

### Role-reveal cancellation

Both pass-phone and role-card screens will expose a Back to Settings action. When used after a role may have been seen, the app asks for confirmation, clears the selected word and all role assignments, resets reveal state, and returns to game settings while preserving player names and selected settings.

No partially revealed round can be resumed with stale roles.

## Custom Words

Custom words remain stored locally in UserDefaults.

New entries require:

- A non-empty value after trimming whitespace and newlines.
- At most 50 user-perceived characters.
- No case-insensitive duplicate of another custom word.
- A selected difficulty.
- An optional built-in category tag used only as a meaningful imposter hint.

The service will return a typed add result so the UI can explain empty, overly long, and duplicate input instead of failing silently.

Legacy decoded entries remain backward compatible because categoryId stays optional. Empty, whitespace-only, duplicate, and otherwise unusable legacy entries are excluded from gameplay calculations without rewriting or deleting the user's stored data. An invalid or missing category identifier behaves as no hint.

Custom Words will be accessible from both Home Settings and Game Settings. Opening it from Game Settings must not discard entered player names.

## Role Reveal, Accessibility, and Secret Protection

The swipe-to-flip interaction remains available, but it will no longer be the only way to continue.

Before reveal:

- A visible Reveal Role button is available.
- The card exposes a VoiceOver reveal action and an accurate hint.
- The secret front face is hidden from accessibility.

After reveal:

- The back face is hidden from accessibility.
- Accessibility focus moves to a concise role summary.
- The existing Next Player or Start Game button remains available.

Settings toggles will announce their visible titles. Category and difficulty chips will expose selected state. Increment and decrement controls will have meaningful labels and disabled states. Important controls must remain usable with VoiceOver, Switch Control, and larger text.

When scene phase is not active, ContentView will cover the game with an opaque branded privacy shield so secret roles and words do not appear in app-switcher snapshots.

## Motion and Layout

The app will honor Reduce Motion:

- Continuous background-orb, shimmer, glow, and card-back loops stop.
- Card reveals use a non-rotating state change.
- Confetti and shake effects are omitted.
- Entrance transitions become simple opacity changes or immediate state changes.

Normal animations remain unchanged when Reduce Motion is disabled.

Fixed display fonts used for long player names, secret words, and role text will use scaled metrics or semantic styles with appropriate line wrapping and minimum scale behavior. Small and large iPhone layouts must not clip primary controls at accessibility text sizes.

## Privacy Policy

Settings will contain an in-app Privacy Policy screen stating:

- The app has no accounts.
- The app does not collect, transmit, sell, share, or track personal data.
- Player names, settings, and custom words remain on the device in UserDefaults.
- Deleting the app removes its locally stored data.
- Privacy questions can be sent through the developer contact shown on the App Store listing.

The local policy and PrivacyInfo.xcprivacy must describe the same behavior. The repository will also contain copy the owner can publish on the DeenPath site.

The owner has explicitly chosen to set or update the public privacy-policy URL in App Store Connect later. The implementation will not contain a fabricated URL or a nonfunctional placeholder.

## Word-Bank Curation

### Existing categories

Every existing category and difficulty list will remain at exactly 30 entries. Existing content will be changed only when there is a high-confidence problem:

- Category mismatch.
- Malformed spelling or title.
- Ambiguous bare common noun used as a specific character or object.
- Excessive obscurity even for the hard list.
- Poor suitability for spoken clues.
- Clear family-audience mismatch.
- Duplicate inside the same category and difficulty list.

Each removal receives a one-for-one replacement of comparable difficulty. Cross-category duplicates are permitted only when the same word naturally belongs in both contexts; duplicates within a single list are prohibited.

The reviewed high-confidence changes include malformed movie and holiday titles, non-professions in Jobs & Professions, specialist technology acronyms, misclassified emotions, ambiguous superhero entity names, and family-audience outliers such as Wine Tasting and Oldboy. Each proposed replacement will be rechecked against the complete file before editing to avoid introducing duplicates.

### New people categories

WordData.json will add:

1. creators — Streamers & Creators
2. athletes — Athletes
3. celebrities — Celebrities

Each category contains exactly 30 kids/easy, 30 medium, and 30 hard entries, for 270 new entries and 2,070 built-in entries overall.

People-category rules:

- Use static names only; the app performs no runtime lookup.
- Use broadly recognizable and durable public figures.
- Avoid politicians, short-lived viral personalities, controversial or primarily adult-content figures, and ambiguous common first names.
- Do not use images, logos, quotations, biographical claims, or endorsement wording.
- Do not duplicate a person across the three new categories or across difficulty levels.
- Athletes span multiple sports, eras, genders, and regions.
- Celebrities focus on actors, musicians, and television or media figures who are not primarily classified as athletes or internet creators.
- Streamers & Creators are internet-native creators with sustained mainstream recognition.

Difficulty means:

- kids/easy: near-household recognition for a general family audience.
- medium: widely known but less universal.
- hard: still mainstream enough to be recognized by an informed party-game group, not a niche specialist list.

Color+Theme.swift will receive stable colors for the three new identifiers. Existing dynamic category loading and selection behavior will be reused.

## Branding and Copy

User-facing branding will consistently say Imposter Hunt. Existing references to Find The Imposter in onboarding or settings copy will be updated where they name the product rather than the Xcode target.

The Settings version string will be read from CFBundleShortVersionString and CFBundleVersion instead of being hardcoded. Singular and plural word counts, validation messages, accessibility labels, and tutorial wording will be corrected.

README.md, WARP.md, and CLAUDE.md will be updated only where their current release requirements or architecture descriptions become inaccurate.

## Automated Testing

The Xcode project will add Find The ImposterTests and Find The ImposterUITests targets.

GameSettings and CustomWordService will accept an injected UserDefaults instance with UserDefaults.standard as the production default. GameViewModel will accept its existing dependencies through defaulted initializer parameters. Tests will use isolated UserDefaults suites and real production types rather than global persisted state.

Unit coverage will include:

- All starting-player indices, including imposter indices, are eligible.
- Each hint mode produces the documented behavior.
- Role assignment respects player and imposter counts.
- Back to Settings clears secret round state but preserves setup state.
- Player-name validation covers blanks, trimming, duplicates, length, and boundary counts.
- Game-start validation distinguishes missing difficulty, missing category, and empty filtered pools.
- Custom-word validation covers trimming, newlines, duplicates, length, optional categories, and backward decoding.
- Unusable legacy custom entries do not enter gameplay.
- WordData.json contains 23 unique categories.
- Every category has exactly 30 entries for kids, medium, and hard.
- The built-in bank contains exactly 2,070 non-empty entries.
- Each category/difficulty list is internally unique.
- All three people categories contain 90 unique names and do not overlap one another.
- Settings persistence works in an isolated suite.

UI coverage will include:

- First-launch onboarding can be completed.
- Three valid players can reach game settings.
- Invalid duplicate names cannot proceed.
- A round can begin with the default selections.
- Role reveal works through the button without a drag gesture.
- A reveal can be cancelled back to settings.
- Settings exposes Custom Words and Privacy Policy.

## Manual Verification

Verification will use the currently installed Xcode and available iOS Simulator runtimes:

1. Run the full unit and UI test targets.
2. Build Debug for an available small iPhone simulator.
3. Build and manually inspect on an available large iPhone simulator.
4. Build Release for generic iOS with signing disabled.
5. Run the static analyzer in Release.
6. Produce an archive when local signing permits it.
7. Validate PrivacyInfo.xcprivacy with plutil.
8. Confirm the App Store icon is 1024 by 1024 and has no alpha channel.
9. Inspect the built bundle for PrivacyInfo.xcprivacy and absence of the three unused source-art PNG files.
10. Exercise onboarding, tutorial replay, settings, custom words, 3-player and 12-player setup, all hint modes, role reveal, cancellation, play, end-game reveal, play again, and change settings.
11. Inspect accessibility labels and state using the simulator accessibility tree.
12. Test Reduce Motion and accessibility text sizes.
13. Background and foreground the app during role reveal and confirm the privacy shield protects the snapshot.
14. Capture required iPhone App Store screenshots from the verified build.
15. Review the complete diff for unrelated changes, leaked secrets, stale copy, and unintended bundle contents.

No claim of App Store upload validation will be made unless a signed archive is actually validated with Apple's service.

## App Store Submission Package

The repository will receive an AppStore directory containing:

- Submission.md with final name, subtitle, description, keywords, category, privacy-label answers, age-rating guidance, content-rights guidance, reviewer notes, and exact verification performed.
- PrivacyPolicy.md containing the publishable policy copy that matches the in-app screen and privacy manifest.
- Screenshots containing the required verified iPhone captures.

Public privacy-policy and support URLs remain owner-controlled App Store Connect fields. No App Store Connect values will be changed by the implementation.

## Expected File Impact

Existing files expected to change:

- Find The Imposter.xcodeproj/project.pbxproj
- Find The Imposter/Assets.xcassets/AppIcon.appiconset/AppIcon.png
- Find The Imposter/PrivacyInfo.xcprivacy
- Find The Imposter/Resources/WordData.json
- Find The Imposter/Utilities/Constants.swift
- Find The Imposter/Utilities/Extensions/Color+Theme.swift
- Find The Imposter/Utilities/Extensions/View+Animations.swift
- Find The Imposter/Models/Player.swift
- Find The Imposter/Models/CustomWord.swift
- Find The Imposter/Models/GameSettings.swift
- Find The Imposter/Services/CustomWordService.swift
- Find The Imposter/ViewModels/GameViewModel.swift
- Find The Imposter/ContentView.swift
- Find The Imposter/Views/PlayerSetup/PlayerRowView.swift
- Find The Imposter/Views/PlayerSetup/PlayerSetupView.swift
- Find The Imposter/Views/GameSetup/GameSettingsView.swift
- Find The Imposter/Views/GameSetup/CategoryPickerView.swift
- Find The Imposter/Views/GameSetup/DifficultyPickerView.swift
- Find The Imposter/Views/CustomWords/AddWordRow.swift
- Find The Imposter/Views/CustomWords/CustomWordRow.swift
- Find The Imposter/Views/CustomWords/CustomWordsView.swift
- Find The Imposter/Views/Home/HomeView.swift
- Find The Imposter/Views/Home/SettingsView.swift
- Find The Imposter/Views/Components/AnimatedBackground.swift
- Find The Imposter/Views/RoleReveal/RoleRevealContainerView.swift
- Find The Imposter/Views/RoleReveal/PassPhoneView.swift
- Find The Imposter/Views/RoleReveal/FlippableCardView.swift
- Find The Imposter/Views/RoleReveal/CardBackView.swift
- Find The Imposter/Views/RoleReveal/RoleRevealView.swift
- Find The Imposter/Views/RoleReveal/RoleCardView.swift
- Find The Imposter/Views/Playing/StartGameView.swift
- Find The Imposter/Views/EndGame/EndGameView.swift
- Find The Imposter/Views/EndGame/ImposterRevealView.swift
- Find The Imposter/Views/EndGame/WordRevealView.swift
- Find The Imposter/Views/Onboarding/OnboardingView.swift
- Find The Imposter/Views/Onboarding/OnboardingPageView.swift
- README.md
- WARP.md
- CLAUDE.md

New files expected:

- Find The Imposter.xcodeproj/xcshareddata/xcschemes/Find The Imposter.xcscheme
- Find The Imposter/Views/Home/PrivacyPolicyView.swift
- Find The ImposterTests/GameViewModelTests.swift
- Find The ImposterTests/GameSettingsTests.swift
- Find The ImposterTests/CustomWordServiceTests.swift
- Find The ImposterTests/WordDataServiceTests.swift
- Find The ImposterUITests/ImposterHuntUITests.swift
- AppStore/Submission.md
- AppStore/PrivacyPolicy.md
- AppStore/Screenshots/ verified PNG files

If investigation during implementation requires a file outside this list or changes a documented behavior, work stops for renewed scope approval.

## Risks and Mitigations

- Existing uncommitted work could be overwritten. Mitigation: inspect each overlapping diff before patching and preserve its intent.
- Random behavior could create flaky tests. Mitigation: inject deterministic randomness only at the internal selection boundary.
- Accessibility changes could expose secret content. Mitigation: explicitly hide the inactive card face and inspect the simulator accessibility tree before and after reveal.
- People lists can become stale or controversial. Mitigation: favor durable mainstream names, use static text only, and avoid political or short-lived figures.
- New content could break JSON loading. Mitigation: schema, count, uniqueness, and runtime-load tests run before UI QA.
- iPhone-only scope could surprise existing iPad users. Mitigation: this is version 1.0 with no released native-iPad build identified; preserve iPhone compatibility mode behavior rather than claiming native iPad support.
- A build can compile but still fail App Store signing or upload validation. Mitigation: report local archive status precisely and leave external validation as an explicit handoff unless credentials and confirmation are provided.

## Rollback

All implementation changes remain on prepare-app-store until final verification. No database or remote migration exists. Before push or merge, the complete diff can be reverted as ordinary Git changes. Existing user-authored changes will not be reset or discarded.

No commit, push, App Store Connect mutation, or PR merge occurs until the user receives the final verification report and gives the required explicit confirmation.
