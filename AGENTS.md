# AGENTS.md

## Project Overview

SwissCroche is a privacy-focused iOS call blocking app using CallKit, adapted for Switzerland from the [Saracroche](https://codeberg.org/cbouvat/saracroche-ios) project (GPLv3). Swift-only, no external dependencies. Target: iOS 15.0+, Swift 5.9+, Xcode 15.0+.

## Architecture

Three targets sharing data via App Groups (`group.ch.swisscroche.app`):

- **swisscroche** (main app): SwiftUI + MVVM. Stores patterns in CoreData, orchestrates updates.
- **blocker** (Call Directory extension): Reads action/numbers from shared UserDefaults, applies block/identify/remove to CallKit directory.
- **filter** (Message Filter extension): Checks incoming SMS senders against CoreData patterns (read-only).

Plus `shared/`, a synchronized folder compiled into `swisscroche`, `blocker` and `filter`, and `swisscrocheTests/`, a unit test bundle hosted by the main app.

`filter/DataModel.xcdatamodeld` is a symlink to `swisscroche/Database/DataModel.xcdatamodeld` — keep it pointing there if folders are ever renamed.

**Inter-process data flow (critical):**

1. Main app writes `action` + `numbers` to shared UserDefaults via `SharedUserDefaultsService`
2. Main app calls `CXCallDirectoryManager.reloadExtension()` to wake the blocker extension
3. Blocker extension reads and clears shared UserDefaults, then applies the action incrementally
4. For SMS filtering, the filter extension reads CoreData directly (read-only) from the app group container

## Conventions

- **Don't commit code** unless explicitly asked.
- All app configuration lives in `shared/AppConstants.swift` — do not hardcode values elsewhere. It is compiled into the app and the `blocker`/`filter` extensions, so both can reference it directly.
- App Groups identifier: `group.ch.swisscroche.app`. Blocker extension bundle ID: `ch.swisscroche.app.blocker`.
- Pure logic that extensions and the app both need (pattern expansion, matching) belongs in `shared/` so it stays unit-testable.
- The block list is bundled at `swisscroche/Resources/SwissList.json` (BAKOM 090x premium-rate prefixes) and loaded by `ListService` — no network fetch.
- CoreData entity `Pattern` uses Xcode code generation (`codeGenerationType="class"`, `representedClassName=".Pattern"`) — do not manually create a `Pattern.swift` file.

## Commands

```bash
make lint       # Format Swift code (REQUIRED after changes)
make build      # Build (REQUIRED after changes)
make test       # Run the unit tests on a simulator
```
