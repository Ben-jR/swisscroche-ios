import Foundation

/// Application-wide constants
struct AppConstants {
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"
  static let backgroundServiceIdentifier = "com.cbouvat.saracroche.background-update"
  static let coreDataModelName = "Database"
  static let apiBaseURL = "https://app.saracroche.org/api/v1"
  static let apiReportURL = "\(apiBaseURL)/reports"
  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"
  static let backgroundUpdateInterval: TimeInterval = 6 * 60 * 60
  static let listDownloadInterval: TimeInterval = 24 * 60 * 60
  static let patternRetryDelay: TimeInterval = 2 * 60 * 60
  static let patternFullResetDays: Int = 20
  static let notificationReminderInterval: TimeInterval = 15 * 24 * 60 * 60
  static let donationDismissInterval: TimeInterval = 30 * 24 * 60 * 60
  static let numberChunkSize = 10_000
  static let intentTimeoutDelay: UInt64 = 25_000_000_000
}
