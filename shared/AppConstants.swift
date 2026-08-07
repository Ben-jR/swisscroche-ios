import Foundation

/// Application-wide constants, shared by the app and its extensions
struct AppConstants {
  static let appGroupIdentifier = "group.ch.swisscroche.app"
  static let callDirectoryExtensionIdentifier = "ch.swisscroche.app.blocker"
  static let backgroundServiceIdentifier = "ch.swisscroche.app.background-update"
  static let coreDataModelName = "DataModel"
  static let coreDataStoreFilename = "DataModel.sqlite"

  /// Name of the block list bundled with the app (see `swisscroche/Resources`)
  static let bundledListResourceName = "SwissList"

  /// Public URL the block list is fetched from.
  ///
  /// A plain anonymous GET of a static file — no identifiers are sent. The bundled
  /// list stays the fallback, so the app works offline and if this is unreachable.
  static let remoteListURL = "https://swisscroche.pages.dev/SwissList.json"

  /// Cached copy of the last successfully fetched remote list, in the App Group container.
  static let remoteListCacheFilename = "RemoteSwissList.json"

  /// How long a fetch may take before falling back to the bundled list.
  static let remoteListRequestTimeout: TimeInterval = 15

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
    /// Version string of the list currently applied to CoreData
    static let appliedListVersion = "appliedListVersion"
  }
}
