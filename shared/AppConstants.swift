import Foundation

/// Application-wide constants, shared by the app and its extensions
struct AppConstants {
  static let appGroupIdentifier = "group.ch.swisscroche.app"
  static let callDirectoryExtensionIdentifier = "ch.swisscroche.app.blocker"
  static let backgroundServiceIdentifier = "ch.swisscroche.app.background-update"
  static let healthCheckServiceIdentifier = "ch.swisscroche.app.healthcheck"
  static let coreDataModelName = "DataModel"
  static let coreDataStoreFilename = "DataModel.sqlite"
  static let apiBaseURL = "https://app.saracroche.org/api/v1"
  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"

  // API v2 URLs
  static let apiBaseURLV2 = "https://app.saracroche.org/api/v2"
  static let apiHealthCheckURL = "\(apiBaseURLV2)/health-check"
  static let apiListsURL = "\(apiBaseURLV2)/lists"
  static let apiReportsURL = "\(apiBaseURLV2)/reports"

  static let backgroundUpdateInterval: TimeInterval = 6 * 60 * 60
  static let listDownloadInterval: TimeInterval = 24 * 60 * 60
  static let patternRetryDelay: TimeInterval = 2 * 60 * 60
  static let patternFullResetDays: Int = 20
  static let notificationReminderInterval: TimeInterval = 15 * 24 * 60 * 60
  static let donationDismissInterval: TimeInterval = 30 * 24 * 60 * 60
  static let numberChunkSize = 10_000
  static let intentTimeoutDelay: UInt64 = 25_000_000_000

  /// Keys of the shared UserDefaults bridge between the app and the Call Directory extension
  struct SharedDefaultsKeys {
    static let action = "action"
    static let numbers = "numbers"
    static let organizationAPIKey = "organizationAPIKey"
    static let lastHealthCheckAt = "lastHealthCheckAt"
  }

  /// Keys for UserDefaults.standard (app-specific storage)
  struct DefaultsKeys {
    static let lastListDownloadAt = "lastListDownloadAt"
    static let lastBackgroundLaunchAt = "lastBackgroundLaunchAt"
    static let lastSuccessfulUpdateAt = "lastSuccessfulUpdateAt"
    static let notificationReminderEnabled = "notificationReminderEnabled"
    static let donationDismissedAt = "donationDismissedAt"
    static let deviceIdentifier = "deviceIdentifier"
    static let lastKnownIOSVersion = "lastKnownIOSVersion"
  }
}
