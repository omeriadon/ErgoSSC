# Ergo, for the Swift Student Challenge

This is Ergo cut down to enter the Swift Student Challenge: boards, logic and the library, all on the device. The full app, with its server, is the separate Ergo repo. Nothing from it comes back here.

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
- `Ergo/` is the iOS app. `Ergo.xcodeproj` links `ErgoKit` as a local package. `Ergo/Boards/` is the board model and `BoardStore`. `Ergo/Scratchpads/` is `LogicScratchpad` and `ScratchpadStore`.
- `ErgoKit/` is the code that doesn't need the app:
  - `ErgoLogic`: entries, parser, checker, `LogicEnglish`, `LogicEquivalence`, the course, and `Canvas/` (argument map, validator, layout; pure, tested with `swift test`)
  - `ErgoCatalog`: the library's JSON files, and a plain-text view of them to search
- `Plans/` has the design docs: plans and the reasons for them, never progress or how something was built.
- `Notes/` says how each area works now (below).

## Notes
This file is only what every agent needs. How one area works, and what must not be broken there, is in `Notes/`. Read the file for an area before changing it, and correct it when a change makes it wrong. Something new goes there, and only here if it applies whatever is being worked on.

| File | Read it before touching |
|---|---|
| `Notes/Logic.md` | The logic keyboard and editor, the parser and its limits, `LogicChecker`, `LogicEnglish`, scratchpads, the course |
| `Notes/Boards.md` | `Board`, `BoardStore`, sources and regions, the UIKit canvas and its hosted SwiftUI boxes, the statement editor |
| `Notes/Library.md` | The library's entries, `LibraryCatalog`, Describe It and the on-device model |

## Building and testing
Xcode is a beta at a non-default path. Prefix every `xcodebuild` and `swift` command with its `DEVELOPER_DIR`.

```sh
export DEVELOPER_DIR="/Applications/Xcode 27.3 beta 1.app/Contents/Developer"
xcodebuild -project Ergo.xcodeproj -scheme Ergo -configuration Debug -destination 'generic/platform=iOS Simulator' build
(cd ErgoKit && swift test)
```

- The project uses the new `Ergo.xcodeproj/project.xcproj` format with a folder-synced `Ergo/` group, so new files are picked up automatically.
- The app build fails when a view's `body` takes over 500 ms to type-check. Keep bodies small.
- The app has no test target. Tests are ErgoKit's.
- Stress tests take a seed (`SeededRandom`) so a failure repeats. Keep what they build small: a test that expands or nests without a bound can take the machine's memory with it.
- `Checks/` only holds the dither, catalog and library precondition scripts. Run them with the Xcode MCP `RunCodeSnippet`.

## Conventions
- Default actor isolation is `MainActor`. Model and logic types that must work off the main actor are marked `nonisolated`.
- Tabs for indentation, and `case` indented inside `switch`.
- Persisted settings use sindresorhus/Defaults: keys in `Ergo/Other/Defaults.swift`, read with `@Default(.key)` in views.
- Migrations don't matter: `Statement`, `Link`, `Board`, `LogicScratchpad` and `LogicKeyboardEntry` can change freely, even though they're saved in Defaults.
- User-facing errors are worded like Swift compiler diagnostics. Anything worth interrupting for goes to `StatusBadgeManager.shared` (`addBadge`, or `present(error:title:)`), which draws over sheets.
- Never call an App Intent's `perform()` from app code: `@Dependency` only resolves inside the system's own intent flow, and crashes outside it. Call the `NavigationManager` method the intent calls.
- `Ergo/Special/PrivacyInfo.xcprivacy` needs a new entry when the app calls another required-reason API. The app collects nothing.

## Navigation
- A sheet belongs to a tab or to the whole app. `BoardSheet` and `LogicSheet` live with their tabs, each with its own slot on `NavigationManager`, and only show while that tab is selected: leaving hides it and coming back restores it. `AppSheet` (settings, the scanner) shows over any tab.
- `ContentView` presents them all from `visibleSheet`, so a swap is SwiftUI replacing one sheet. `dismissSheet()` closes what's on screen, so call it before changing tab. `reveal(tab)` goes to a tab with nothing over it.
