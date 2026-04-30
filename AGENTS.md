# AGENTS.md

## Project Overview

Saracroche is a privacy-focused iOS call blocking app using CallKit. Swift-only, no external dependencies (no SPM/CocoaPods/Carthage). Target: iOS 15.0+, Swift 5.9+, Xcode 15.0+.

## Four-Target Architecture

The project has four targets that share data via App Groups (`group.com.cbouvat.saracroche`):

- **saracroche** (main app): SwiftUI + MVVM. Stores patterns in CoreData, orchestrates updates.
- **blocker** (Call Directory extension): Reads action/numbers from shared UserDefaults when the main app reloads it, then applies block/identify/remove operations to the CallKit directory.
- **unwanted** (Unwanted Communication Reporting extension): Reports spam calls/SMS.
- **filter** (Message Filter extension): Checks incoming SMS senders against CoreData patterns (read-only).

**Inter-process data flow (critical):**
1. Main app writes `action` + `numbers` to shared UserDefaults via `SharedUserDefaultsService`
2. Main app calls `CXCallDirectoryManager.reloadExtension()` to wake the blocker extension
3. Blocker extension reads and clears shared UserDefaults, then applies the action incrementally
4. For SMS filtering, the filter extension reads CoreData directly (read-only) from the app group container

## Key Technical Details

- **Pattern system**: Phone numbers use wildcard patterns (e.g., `33899######` where `#` matches any digit). `PhoneNumberHelpers.expandBlockingPattern()` expands patterns into individual numbers, processed in chunks (`AppConstants.numberChunkSize`).
- **Pattern lifecycle**: `pending` (completedDate=nil) → `completed` (completedDate set) → `removed` (action prefixed with `remove_`) → deleted. Expired completed patterns get randomly reset for reprocessing (see `AppConstants.patternResetPercentage`).
- **CoreData model name gotcha**: `NSPersistentContainer(name: "DataModel")` matches the `DataModel.xcdatamodeld` folder name. `AppConstants.coreDataModelName = "Database"` is defined but **not used** in container creation — do not use it for `NSPersistentContainer`.
- **CoreData store location**: SQLite file is in the App Group container directory (not the default sandbox), so extensions can access it.
- **Background updates**: `BGProcessingTask` every 6 hours (`AppConstants.backgroundUpdateInterval`), requires network and external power. Registered in `AppDelegate`.
- **Custom font**: Uses AtkinsonHyperlegibleNextVF (configured in `App.swift` and `Info.plist` UIAppFonts).

## Code Style

- Format after changes: `swift-format --in-place --recursive .` (or `make lint`).
- No Objective-C — Swift-only project.

## Conventions

- **Don't commit code** unless explicitly asked.
- All app configuration lives in `AppConstants.swift` — do not hardcode values elsewhere.
- App Groups identifier is `group.com.cbouvat.saracroche`. Blocker extension bundle ID is `com.cbouvat.saracroche.blocker`.
- Some extension files hardcode the App Group string instead of referencing `AppConstants` (e.g., `CallDirectoryHandler.swift:16`, `MessageFilterService.swift:11`) — be aware of this gap when making changes.
- CoreData entity `Pattern` uses Xcode code generation (`codeGenerationType="class"`, `representedClassName=".Pattern"`) — do not manually create a `Pattern.swift` file.

## Commands

```bash
# Format Swift code (REQUIRED after changes)
swift-format --in-place --recursive .
# or:
make lint

# Build
xcodebuild -project saracroche.xcodeproj build
```
