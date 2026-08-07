import Foundation

/// Service for managing persistent data storage
class UserDefaultsService {

  private let userDefaults: UserDefaults
  private typealias Keys = AppConstants.DefaultsKeys

  init() {
    userDefaults = UserDefaults.standard
  }

  func setLastSuccessfulUpdateAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastSuccessfulUpdateAt)
  }

  func getLastSuccessfulUpdateAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastSuccessfulUpdateAt) as? Date
  }

  func clearLastSuccessfulUpdateAt() {
    userDefaults.removeObject(forKey: Keys.lastSuccessfulUpdateAt)
  }

  func shouldUpdateList() -> Bool {
    guard let lastUpdate = getLastListDownloadAt() else {
      return true  // First time, always update
    }

    return Date().timeIntervalSince(lastUpdate) > AppConstants.listDownloadInterval
  }

  /// Version of the list currently reflected in CoreData, used to skip redundant syncs
  /// and to apply a new list as soon as its version changes.
  func setAppliedListVersion(_ version: String) {
    userDefaults.set(version, forKey: Keys.appliedListVersion)
  }

  func getAppliedListVersion() -> String? {
    return userDefaults.string(forKey: Keys.appliedListVersion)
  }

  func clearAppliedListVersion() {
    userDefaults.removeObject(forKey: Keys.appliedListVersion)
  }

  func setLastListDownloadAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastListDownloadAt)
  }

  func getLastListDownloadAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastListDownloadAt) as? Date
  }

  func clearLastListDownloadAt() {
    userDefaults.removeObject(forKey: Keys.lastListDownloadAt)
  }

  func setLastBackgroundLaunchAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastBackgroundLaunchAt)
  }

  func getLastBackgroundLaunchAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastBackgroundLaunchAt) as? Date
  }

  func clearLastBackgroundLaunchAt() {
    userDefaults.removeObject(forKey: Keys.lastBackgroundLaunchAt)
  }

  func setNotificationReminderEnabled(_ enabled: Bool) {
    userDefaults.set(enabled, forKey: Keys.notificationReminderEnabled)
  }

  func getNotificationReminderEnabled() -> Bool {
    return userDefaults.bool(forKey: Keys.notificationReminderEnabled)
  }

  func clearNotificationReminderEnabled() {
    userDefaults.removeObject(forKey: Keys.notificationReminderEnabled)
  }

  func setLastKnownIOSVersion(_ version: String) {
    userDefaults.set(version, forKey: Keys.lastKnownIOSVersion)
  }

  func getLastKnownIOSVersion() -> String? {
    return userDefaults.string(forKey: Keys.lastKnownIOSVersion)
  }

  func clearLastKnownIOSVersion() {
    userDefaults.removeObject(forKey: Keys.lastKnownIOSVersion)
  }

  func setDonationDismissedAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.donationDismissedAt)
  }

  func getDonationDismissedAt() -> Date? {
    return userDefaults.object(forKey: Keys.donationDismissedAt) as? Date
  }

  func clearDonationDismissedAt() {
    userDefaults.removeObject(forKey: Keys.donationDismissedAt)
  }

  func isDonationDismissed() -> Bool {
    guard let dismissedAt = getDonationDismissedAt() else {
      return false
    }
    return Date().timeIntervalSince(dismissedAt) < AppConstants.donationDismissInterval
  }

  func getOrCreateDeviceIdentifier() -> String {
    if let existingID = userDefaults.string(forKey: Keys.deviceIdentifier) {
      return existingID
    }
    let newID = UUID().uuidString.uppercased()
    userDefaults.set(newID, forKey: Keys.deviceIdentifier)
    return newID
  }

  func resetAllData() {
    clearLastListDownloadAt()
    clearLastBackgroundLaunchAt()
    clearLastSuccessfulUpdateAt()
    clearNotificationReminderEnabled()
    clearLastKnownIOSVersion()
    clearDonationDismissedAt()
    clearAppliedListVersion()
  }
}
