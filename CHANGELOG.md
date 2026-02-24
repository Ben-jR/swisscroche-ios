# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.2.1] - 2026-02-24

### Added
- **French List Metadata**: New `FrenchListMetadata` struct and `getFrenchListMetadata()` method in `PatternService` for extracting metadata from API patterns
- **Background Service**: Converted `BackgroundService` from `ObservableObject` to singleton pattern with shared instance
- **App Delegate**: Added `AppDelegate` for proper background task registration in iOS app lifecycle

### Changed
- **BackgroundService**: Refactored from instance-based to singleton pattern, moved background task registration to AppDelegate
- **PatternService**: Added `returnsObjectsAsFaults = false` to all CoreData fetch requests for better performance
- **ListsViewModel**: Updated `updateFrenchListMetadata()` to use async/await pattern and leverage new metadata service
- **App Architecture**: Moved from `@StateObject` background service to `UIApplicationDelegateAdaptor` for proper background task handling
- Updated app version to 4.2.1

### Optimized
- **App Constants**: Reduced `patternReprocessInterval` from 20 days to 7 days for more frequent pattern reprocessing
- **Number Processing**: Decreased `numberChunkSize` from 10,000 to 5,000 for better memory management
- **Extension Performance**: Reduced `extensionReloadDelay` from 25ms to 20ms for faster extension updates

## [4.2.0] - 2026-02-23

### Added
- **Retry Logic**: Comprehensive retry mechanism for extension updates with configurable retry counts (`maxRetryCount = 10`) and delays
- **Error Handling**: New error enums (`BlockerServiceError`, `CallDirectoryError`, `ListServiceError`) for better error management
- **UI Components**: New card-based home screen components:
  - `HomeActiveCard`: Shows active blocker status with phone number count
  - `HomeDisabledCard`: Shows disabled extension state
  - `HomeInstallCard`: Installation progress card
  - `HomeUpdateCard`: Update available card
  - `HomeFeatureCards`: Feature cards for SMS filter and call reporting
- **Setup Sheets**: New setup sheets for additional features:
  - `SmsFilterSetupSheet`: Guide for SMS filtering setup
  - `CallReportingSetupSheet`: Guide for call reporting setup
  - `UpdateErrorSheet`: Error handling for failed updates
  - `UpdateInProgressSheet`: Progress indicator for updates
- **View Models**: New `BlockerStatusViewModel` and `UserPreferencesViewModel` for better state management
- **Constants**: New timing constants for extension management (`extensionResetDelay`, `extensionReloadDelay`, `extensionReloadRetryDelay`)

### Changed
- **BlockerService**: Complete refactoring with separate methods for background/foreground updates, progress callbacks, and improved retry logic
- **BackgroundService**: Enhanced background task handling with better cancellation support and error handling
- **HomeNavigationView**: Complete UI restructuring from list-based to card-based layout with improved navigation
- **CallDirectoryHandler**: Improved extension handling with better action processing and error logging
- **Pattern Processing**: Refactored from batch processing to individual pattern processing with progress tracking
- **Error Handling**: Moved error enums to separate files and improved error descriptions
- Updated app version to 4.2.0

### Removed
- **ExtensionsSetupSheet**: Replaced with separate SMS filter and call reporting setup sheets
- **Batch Processing**: Removed `maxNumbersPerBatch` limit in favor of individual pattern processing
- **Legacy UI Components**: Removed old home screen components in favor of new card-based design

## [4.1.1] - 2026-02-19

### Added
- Call directory reset functionality with new `reset` action that clears all blocking and identification entries
- Support for 3xx redirect status codes in APIService

### Changed
- Refactored CallDirectoryHandler with improved code structure and separate methods for different actions
- Increased numberChunkSize from 5,000 to 10,000 for better performance
- Improved error handling and logging throughout the codebase
- Fixed potential retain cycle in BackgroundService with weak self reference
- Enhanced JSON parsing error handling in ListAPIService
- Replaced hardcoded 24-hour interval with AppConstants.listDownloadInterval
- Cleaned up redundant code and unused imports

### Fixed
- Corrected string interpolation in CallDirectoryService error logging
- Removed unused UserDefaultsService dependency from ListAPIService
- Fixed entitlements configuration in filter and unwanted extensions

## [4.1.0] - 2026-02-15

### Changed
- Renamed "Numbers" functionality to "Lists" throughout the application (`NumbersViewModel` → `ListsViewModel`, `NumbersNavigationView` → `ListsNavigationView`)
- Updated UI labels from "Numéros" to "Listes" in tab bar
- Improved and expanded project documentation in README.md

### Removed
- Email contact feature in settings (redundant with direct FAQ access)
- `UIDevice+Extensions.swift` file

## [4.0.0] - 2026-02-11

### Added
- SMS filtering extension (`filter` target) with `MessageFilterExtension` and `MessageFilterService`
- Unwanted Communication Reporting extension (`unwanted` target) for spam call reporting
- CoreData database layer with `CoreDataStack` for pattern storage
- New services: `BackgroundService`, `BlockerService`, `ListService`, `PatternService`, `NotificationService`, `UserDefaultsService`
- Network layer refactoring with `APIService`, `ListAPIService`, `ReportAPIService`
- New UI components: `BenefitRow`, `PatternRow`, `ReportChoiceButton`
- New sheets: `AddPatternSheet`, `BusinessCodeSheet`, `DebugSheet`, `ExtensionsSetupSheet`, `InfoSheet`, `ReinstallSheet`, `ResetSheet`
- `NumbersNavigationView` for managing custom blocking patterns
- `NumbersViewModel` for pattern management logic
- Custom font `AtkinsonHyperlegibleNextVF-Variable.ttf`
- `LaunchIcon` image asset
- `GlassAppIcon` alternative icon
- `Logger` helper for structured logging
- `PhoneNumberHelpers` utility
- New enums: `BlockerExtensionStatus`, `BlockerUpdateStatus`, `HTTPMethod`, `NetworkError`
- `Font+App` extension for custom typography
- `AGENTS.md` and `CLAUDE.md` project documentation

### Changed
- Major architecture refactoring from monolithic to MVVM with services
- Refactored `CallDirectoryHandler` with incremental update support
- Refactored `BlockerViewModel` with new service-based architecture
- Refactored `ReportViewModel` to use new API services
- Moved navigation views into `Navigation/` subfolder
- Restructured `AppConstants` location
- Updated `SharedUserDefaultsService` interface
- Reworked `CallDirectoryService` implementation
- Updated `DonationSheet` layout
- Updated `CustomButtonStyle`
- Renamed app icon assets (`Icone.png` → `Icon.png`, `Icone transparent.png` → `IconAlpha.png`)
- Updated repository links to Codeberg
- Updated .gitignore to exclude `.claude/` and `.vibe/` directories
- Changed license terms

### Removed
- `FUNDING.yml` file
- `copilot-instructions.md` (replaced by `AGENTS.md`)
- `Config.swift.example`
- `blocked-patterns.json` (patterns now fetched from API)
- `NetworkService.swift` (replaced by new network layer)
- `PhoneNumberService.swift`
- `HomeNavigationView.swift` (moved to `Navigation/`)
- `SettingsNavigationView.swift` (moved to `Navigation/`)
- `SaracrocheView.swift` (replaced by new version in `Views/`)
- Old sheets: `ActionErrorSheet`, `DeleteBlockerSheet`, `DeleteFinishedSheet`, `UpdateListFinishedSheet`, `UpdateListSheet`
- `BlockerActionState` and `BlockerExtensionStatus` models (replaced by enums)
- `UserDefaults+Extensions.swift`

## [3.17.0] - 2025-11-28

### Changed
- Consolidated help and privacy links into `SettingsNavigationView`

### Removed
- `HelpNavigationView` (functionality moved to settings)

## [3.16.0] - 2025-11-27

### Changed
- Updated current blocklist version to 8

## [3.15.0] - 2025-11-27

### Changed
- Updated blocked patterns references
- Incremented blocklist version to 7

## [3.14.1] - 2025-11-20

### Added
- `Accept` header to network request in `NetworkService`

## [3.14.0] - 2025-11-11

### Changed
- Updated URL in `SettingsNavigationView` to point to the official site
- Refactored phone number handling to use `Int64`
- Updated API endpoint

## [3.13.1] - 2025-10-15

### Fixed
- Added fake number entry during reset of numbers list in `CallDirectoryHandler`

## [3.13.0] - 2025-10-03

### Changed
- Updated `currentBlocklistVersion` to 6
- Updated email address in code of conduct, security policy, and help/settings views

### Fixed
- Fixed `reportPhoneNumber` method to use a hardcoded URL for reporting

### Removed
- Validation for French phone number format in `validatePhoneNumber` method

## [3.12.2] - 2025-08-18

### Changed
- Refactored `ReportViewModel` and `ReportNavigationView` to remove loading state and improve phone number formatting

## [3.12.1] - 2025-08-15

### Changed
- Refactored button styles and updated `ReportNavigationView` to use `List` instead of `Form`

## [3.12.0] - 2025-08-14

### Changed
- Refactored Help, Home, Report, Settings, and Donation views for improved clarity and consistency

## [3.11.0] - 2025-08-12

### Added
- `.editorconfig` and `Makefile` for consistent formatting and build help
- `HelpFAQSection` and `HelpSupportSection` components for improved user assistance

### Changed
- Refactored Help, Support Sections and Sheets

## [3.10.0] - 2025-08-08

### Added
- New app icon tinted variant

### Fixed
- Fixed action clearing by calling `checkBlockerExtensionStatus` instead of `checkExtensionStatusAction`

### Changed
- Refactored blocker action handling and improved UI feedback

## [3.9.0] - 2025-08-07

### Changed
- Refactored app structure and error handling
- Renamed enum cases for consistency
- Refactored UI components across multiple sheets to improve spacing and readability
- Refactored `CallDirectoryHandler` to streamline action handling
- Updated line length guideline to a maximum of 120 characters

### Removed
- Unused `Logger`

## [3.8.0] - 2025-08-06

### Added
- Error handling for blocker actions with `ActionErrorSheet`
- Button to refresh blocker list in `SettingsNavigationView`
- Dark Mode app icon assets

### Changed
- Refactored blocker action handling with updated state management and enhanced UI sheets for update and delete actions
- Enhanced `CallDirectoryHandler` with action handling and logging
- Updated `BlockerViewModel` to reflect extension status and improve state management
- Updated phone number format instruction in `ReportNavigationView`
- Updated corner radius of `CustomButtonStyle`
- Updated JSON file references and incremented blocklist version to 5
- Reduced phone number chunk size from 10,000 to 5,000
- Refactored donation section display logic and improved layout in `HomeNavigationView`
- Streamlined copilot instructions by removing redundant sections

### Removed
- Deprecated `BlockerStatusSheet`

## [3.7.0] - 2025-08-02

### Changed
- Updated deployment target to iOS 15
- Show donation section when blocker is active
- Updated repository links in `CONTRIBUTING.md` and `SettingsNavigationView` to reflect correct URL

## [3.6.0] - 2025-07-31

### Added
- Donation section with support button in `HomeNavigationView`
- New app icon image

### Changed
- Refactored code formatting in multiple files for improved readability
- Enhanced email feedback feature in `SettingsNavigationView` with improved message format and additional device information
- Refactored email body format in `HelpNavigationView` for improved clarity
- Enhanced `HelpNavigationView` with improved layout and additional support information
- Updated section headers and improved app version display in `SettingsNavigationView`
- Refactored README to remove French sections and streamline English descriptions
- Updated README to include Android availability and enhance configuration instructions
- Updated Copilot instructions to specify iOS context and emphasize KISS principles
- Refactored funding model platforms and updated app icon references

## [3.5.0] - 2025-07-07

### Changed
- Enhanced `NetworkError` handling to include server error messages and improve error extraction logic
- Updated blocklist version during update and remove actions

## [3.4.1] - 2025-07-07

### Fixed
- Refactored `CallDirectoryHandler` to streamline action handling and improve code clarity

## [3.4.0] - 2025-07-06

### Added
- Donation button and sheet to `HelpNavigationView` for user support
- `DonationSheet` view with donation options and benefits
- `NetworkService` and `ReportViewModel` for reporting functionality
- Phone number submission and validation in `ReportNavigationView`

### Changed
- Refactored `HomeNavigationView` to enhance user feedback and add donation button functionality
- Refactored `ReportNavigationView` for improved layout and clarity in phone number input
- Refactored color usage in `BlockerStatusSheet` for consistency
- Refactored view models for blocker management
- Reset `blockedNumbers` to 0 when resetting numbers list
- Updated Copilot instructions: enhanced Swift guidelines and added comments requirement

### Removed
- CSV and `generateJson.php`: eliminated unused prefix generation functionality
- Code examples from Copilot instructions

## [3.3.0] - 2025-07-04

### Added
- Reporting functionality in `ReportNavigationView`: phone number submission, validation, UI elements, and server configuration

### Changed
- Updated `.gitignore` to include `Config.swift` for sensitive data protection

## [3.2.0] - 2025-07-03

### Changed
- Enhanced `SettingsNavigationView`: updated button labels, improved bug reporting functionality
- Refactored `HomeNavigationView`: removed commented code, updated button text for clarity
- Refactored `HelpNavigationView`: removed GitHub bug reporting button, enhanced email reporting message
- Updated MAJNUM.csv: removed outdated entries and added new records
- Refactored `CallDirectoryHandler` to simplify action handling and improve logging
- Removed unused timers in `SaracrocheViewModel` and enhanced state management

## [3.1.0] - 2025-07-02

### Changed
- Refactored `HelpNavigationView` to replace `GroupBox` with `DisclosureGroup` for improved content organization
- Refactored `SaracrocheViewModel` to remove timers and improve blocker status checks
- Updated `HomeNavigationView` to call status check on appear and scene phase change
- Refactored `PrefixGenerator` class to encapsulate CSV handling and JSON generation logic
- Reduced chunk size for phone number processing from 50,000 to 10,000
- Updated copilot instructions to clarify comment usage

## [3.0.0] - 2025-06-30

### Added
- `generateJson.php` to process CSV and generate JSON with E.164 prefixes

### Changed
- Refactored `CallDirectoryHandler` and `SaracrocheViewModel` to enhance number handling logic
- Refactored `HomeNavigationView` to streamline blocker status display logic
- Updated `HelpNavigationView` with additional operator names and support donation PayPal link
- Updated phone number pattern handling and incremented blocklist version to 4

### Removed
- Redundant button for reinstalling block list in `SettingsNavigationView`

## [2.1.0] - 2025-06-24

### Added
- Copilot instructions for Swift development
- Privacy policy section to `HelpNavigationView`
- Operator lookup functionality in `ReportNavigationView`
- Details about MAJNUM and MAJRIO files in the prefixes information section

### Changed
- Updated `blocklistVersion` to remove minor version number for consistency
- Refactored blocker extension status display logic and improved user instructions
- Updated block phone number patterns for DVS Connect and added new patterns for Manifone
- Updated blocklist version to 3.0 and added DVS Connect phone number
- Refactored phone number patterns for clarity and consistency in blocking logic
- Updated prefix information section with direct links to MAJNUM and MAJRIO files
- Refactored README.md to simplify descriptions and remove specific references to ARCEP data
- Disabled idle timer during blocker list updates and re-enabled afterwards
- Refactored `HelpNavigationView` to use new `Label` syntax with icons and foreground styles
- Added foreground color to delete button in `SettingsNavigationView`
- Replaced `StoreKit` import with `SwiftUI` in `SaracrocheView.swift`

### Fixed
- Blocker extension status check to return unknown when action state is not nothing

### Removed
- Unnecessary comments from `CallDirectoryHandler.swift`

## [2.0.1] - 2025-06-19

### Changed
- Refactored Help and Settings navigation views to remove `requestReview` closure and open review URL directly
- Formatted code for improved readability and consistency across multiple files
- Updated contact email for reporting unacceptable behavior in Code of Conduct
- Updated security policy contact email

### Removed
- Bug report issue template
- Custom and feature request issue templates
- Supported versions section from security policy

## [2.0.0] - 2025-06-18

### Changed
- Refactored blocker status messages for improved clarity and consistency

## [1.6.0] - 2025-06-17

### Added
- "Informations & Ressources" button and info sheet content
- Request review button to encourage app ratings

### Changed
- Updated iOS deployment target to 16.0 for improved compatibility
- Refined informational text for clarity and conciseness in `ContentView`
- Enhanced info section with icons for better visual appeal
- Enhanced button UI with icons and updated labels
- Simplified delete confirmation message
- Enhanced layout and alignment for improved readability
- Center aligned the "Activer dans les réglages" button
- Refactored `ContentView` layout to enhance user experience and improve blocker status messaging
- Enhanced blocker status messages with emojis and improved timer intervals
- Replaced link to remove the block list by a button
- Translated README sections to French and updated feature descriptions

### Fixed
- Placement of delete list button

### Removed
- Unnecessary comments from `ContentView.swift` and `saracrocheApp.swift`
- Outdated comment about pattern conversion in `CallDirectoryHandler`

## [1.5.0] - 2025-05-16

### Added
- `SECURITY.md` for security policy and vulnerability reporting
- `CONTRIBUTING.md` for contributor guidelines
- `CODE_OF_CONDUCT.md`

### Changed
- Updated iOS deployment target from 18.0 to 15.6
- Refactored phone number handling to use patterns instead of ranges in `SaracrocheViewModel`
- Refactored `ContentView` to use `SaracrocheViewModel` for state management
- Increased status check interval from 1 second to 2.5 seconds
- Updated license to GNU General Public License v3.0
- Fixed email formatting in `CODE_OF_CONDUCT.md` and `SECURITY.md`
- Updated issue templates
- Updated `FUNDING.yml` to format funding platforms
- Updated README.md to enhance app description and installation instructions

## [1.4.0] - 2025-04-02

### Added
- Functionality to inform users about non-blocked phone number ranges
- Ability to remove the blocklist

### Changed
- Refactored blocker status handling and improved UI feedback during installation and deletion processes

## [1.3.0] - 2025-03-27

### Added
- New phone number range to `ContentView`

### Changed
- Updated blocked prefixes message in `ContentView` for clarity

## [1.2.0] - 2025-03-25

### Changed
- Updated blocked numbers threshold for saving to user defaults

### Removed
- Warning message about contact phone numbers in `ContentView`

## [1.1.0] - 2025-03-25

### Added
- Percentage display to blocker update status message
- MIT License
- `FUNDING.yml`

### Changed
- Refactored phone number blocking logic and updated status handling in `CallDirectoryHandler` and `ContentView`
- Refactored blocked numbers storage logic in `CallDirectoryHandler`

## [1.0.5] - 2025-03-24

### Changed
- Changed development region from English to French in project configuration

## [1.0.4] - 2025-03-24

### Changed
- Updated `ContentView` layout and enhanced status messages with icons
- Changed blocked numbers update frequency from every 10 to every 3 for improved responsiveness

## [1.0.3] - 2025-03-24

### Changed
- Changed blocked numbers threshold from 100 to 10 for more frequent updates

## [1.0.2] - 2025-03-24

### Added
- `.editorconfig` file to standardize code formatting

### Changed
- Refactored `CallDirectoryHandler` for improved readability and maintainability
- Fixed formatting issues in multiple files
- Refactored `blockPhoneNumbers` method to improve logging and reduce frequency of blocked numbers update

## [1.0.1] - 2025-03-24

### Changed
- Updated blocker status messages for clarity and adjusted timer intervals
- Refactored `blockPhoneNumbers` method to simplify parameters and improve logging

## [1.0.0] - 2025-03-24

### Added
- Initial release of Saracroche iOS app
- Call blocking with CallKit Call Directory extension
- Phone number pattern-based blocking system
- SwiftUI user interface with blocker status display
