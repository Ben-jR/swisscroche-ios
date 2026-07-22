# AGENTS.md

## Project Overview

Saracroche is a privacy-focused iOS call blocking app using CallKit. Swift-only, no external dependencies. Target: iOS 15.0+, Swift 5.9+, Xcode 15.0+.

## Architecture

Four targets sharing data via App Groups (`group.com.cbouvat.saracroche`):

- **saracroche** (main app): SwiftUI + MVVM. Stores patterns in CoreData, orchestrates updates.
- **blocker** (Call Directory extension): Reads action/numbers from shared UserDefaults, applies block/identify/remove to CallKit directory.
- **unwanted** (Unwanted Communication Reporting extension): Reports spam calls/SMS.
- **filter** (Message Filter extension): Checks incoming SMS senders against CoreData patterns (read-only).

Plus `Shared/`, a synchronized folder compiled into `saracroche`, `blocker` and `filter`, and `saracrocheTests/`, a unit test bundle hosted by the main app.

**Inter-process data flow (critical):**

1. Main app writes `action` + `numbers` to shared UserDefaults via `SharedUserDefaultsService`
2. Main app calls `CXCallDirectoryManager.reloadExtension()` to wake the blocker extension
3. Blocker extension reads and clears shared UserDefaults, then applies the action incrementally
4. For SMS filtering, the filter extension reads CoreData directly (read-only) from the app group container

## Conventions

- **Don't commit code** unless explicitly asked.
- All app configuration lives in `Shared/AppConstants.swift` — do not hardcode values elsewhere. It is compiled into the app and the `blocker`/`filter` extensions, so both can reference it directly.
- App Groups identifier: `group.com.cbouvat.saracroche`. Blocker extension bundle ID: `com.cbouvat.saracroche.blocker`.
- Pure logic that extensions and the app both need (pattern expansion, matching) belongs in `Shared/` so it stays unit-testable.
- CoreData entity `Pattern` uses Xcode code generation (`codeGenerationType="class"`, `representedClassName=".Pattern"`) — do not manually create a `Pattern.swift` file.

## Commands

```bash
make lint                                         # Format Swift code (REQUIRED after changes)
xcodebuild -project saracroche.xcodeproj build    # Build (REQUIRED after changes)
make test                                         # Run the unit tests on a simulator
```
