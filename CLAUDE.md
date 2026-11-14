# Ergo, for the Swift Student Challenge

This is Ergo cut down to enter the Swift Student Challenge: lessons and the library, all on the device. The full app, with its server, is the separate Ergo repo. Nothing from it comes back here.

Being succinct matters far more than having lots of features.

## Ground rules
- Never commit, stage, or otherwise touch git state. Adon manages git.
- Never boot a simulator or run the app/UI tests; it cripples the machine.
- Verification is light. Don't build for small changes. For a big change, build once with `-configuration Debug` only (never Release, no other schemes), and don't re-run suites or builds to double-check. Say plainly what wasn't built or run.
- Match the surrounding code's style. Specialised code (parsers, performance-critical UIKit) can differ, since Adon doesn't write UIKit.
- What anyone wrote is never logged.

## The challenge's rules
- The app is judged offline, so nothing may need the network: no server, no accounts, no sync, no analytics.
- It has to be experienced within three minutes.
- It's submitted as a ZIP of at most 500 MB.
- It's Adon's own work. Open source code is allowed when it's credited.
- No private API anywhere.

## Layout
- `Ergo/` is the iOS app. `Ergo.xcodeproj` links `ErgoKit` as a local package. `Ergo/Lessons/` is the Learn tab.
- `ErgoKit/` is `ErgoCatalog`: the library's JSON files, and a plain-text view of them to search.
- `Packages/` is the open source the app uses (Defaults, FuzzyMatch), copied in and linked as local packages so nothing is fetched. What was trimmed from each, and their credits, are in its `README.md`. Never add a remote package.
- `Plans/` has the design docs: plans and the reasons for them, never progress or how something was built.
- `Notes/` says how each area works now (below).

## Notes
This file is only what every agent needs. How one area works, and what must not be broken there, is in `Notes/`. Read the file for an area before changing it, and correct it when a change makes it wrong. Something new goes there, and only here if it applies whatever is being worked on.

| File | Read it before touching |
|---|---|
| `Notes/Lessons.md` | The Learn tab, `Lesson`, the lesson host and each lesson's pages |
| `Notes/Library.md` | The library's entries, `LibraryCatalog`, Describe It and the on-device model |

## Building and testing
Xcode is a beta at a non-default path. Prefix every `xcodebuild` and `swift` command with its `DEVELOPER_DIR`.

```sh
export DEVELOPER_DIR="/Applications/Xcode 27.3 beta 1.app/Contents/Developer"
xcodebuild -project Ergo.xcodeproj -scheme Ergo -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

- The project uses the new `Ergo.xcodeproj/project.xcproj` format with a folder-synced `Ergo/` group, so new files are picked up automatically.
- The app build fails when a view's `body` takes over 500 ms to type-check. Keep bodies small.
- There are no test targets.
- `Checks/` only holds the dither, catalog and library precondition scripts. Run them with the Xcode MCP `RunCodeSnippet`.

## Conventions
- Default actor isolation is `MainActor`. Model and logic types that must work off the main actor are marked `nonisolated`.
- Tabs for indentation, and `case` indented inside `switch`.
- Persisted settings use sindresorhus/Defaults: keys in `Ergo/Other/Defaults.swift`, read with `@Default(.key)` in views.
- Migrations don't matter: what's saved in Defaults, like each lesson's state, can change freely.
- User-facing errors are worded like Swift compiler diagnostics. Anything worth interrupting for goes to `StatusBadgeManager.shared` (`addBadge`, or `present(error:title:)`), which draws over sheets.
- `Ergo/Special/PrivacyInfo.xcprivacy` needs a new entry when the app calls another required-reason API. The app collects nothing.

## Navigation
- Every sheet is an `AppSheet` (settings, the scanner) and shows over any tab. `ContentView` presents them from `presentedSheet`, so a swap is SwiftUI replacing one sheet. `dismissSheet()` closes what's on screen, so call it before changing tab. `reveal(tab)` goes to a tab with nothing over it.
