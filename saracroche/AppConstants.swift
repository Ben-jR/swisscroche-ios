import Foundation

/// Application-wide constants
struct AppConstants {
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"
  static let backgroundServiceIdentifier = "com.cbouvat.saracroche.background-update"
  static let coreDataModelName = "Database"
  static let apiBaseURL = "https://saracroche.org/api/v1"
  static let apiReportURL = "\(apiBaseURL)/reports"
  static let apiListsURL = "\(apiBaseURL)/lists"
  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"
  static let backgroundUpdateInterval: TimeInterval = 6 * 60 * 60
  static let listDownloadInterval: TimeInterval = 24 * 60 * 60
  static let patternReprocessInterval: TimeInterval = 20 * 24 * 60 * 60
  static let notificationReminderInterval: TimeInterval = 15 * 24 * 60 * 60
  static let numberChunkSize = 10_000
  static let extensionResetDelay: UInt64 = 5 * 1_000_000_000
  static let extensionReloadDelay: UInt64 = 25_000_000
  static let extensionReloadRetryDelay: UInt64 = 2 * 1_000_000_000
  static let maxRetryCount = 10
}
