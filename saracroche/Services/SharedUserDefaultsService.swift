import Foundation

class SharedUserDefaultsService {

  private let userDefaults: UserDefaults?

  // MARK: - Constants
  private typealias Keys = AppConstants.SharedDefaultsKeys

  init() {
    userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
  }

  // MARK: - Action
  func setAction(_ action: String) {
    userDefaults?.set(action, forKey: Keys.action)
  }

  func clearAction() {
    userDefaults?.set("", forKey: Keys.action)
  }

  // MARK: - Numbers

  /// Set the numbers array for processing by the CallDirectory extension
  /// - Parameter numbers: Array of dictionaries containing number and optional name
  func setNumbers(_ numbers: [[String: Any]]) {
    userDefaults?.set(numbers, forKey: Keys.numbers)
  }

  func clearNumbers() {
    userDefaults?.set([], forKey: Keys.numbers)
  }

  // MARK: - Organization API Key

  func setOrganizationAPIKey(_ apiKey: String?) {
    if let apiKey = apiKey {
      userDefaults?.set(apiKey, forKey: Keys.organizationAPIKey)
    } else {
      userDefaults?.removeObject(forKey: Keys.organizationAPIKey)
    }
  }

  func getOrganizationAPIKey() -> String? {
    return userDefaults?.string(forKey: Keys.organizationAPIKey)
  }

  func clearOrganizationAPIKey() {
    userDefaults?.removeObject(forKey: Keys.organizationAPIKey)
  }

  // MARK: - Health Check

  func setLastHealthCheckAt(_ date: Date) {
    userDefaults?.set(date, forKey: Keys.lastHealthCheckAt)
  }

  func getLastHealthCheckAt() -> Date? {
    return userDefaults?.object(forKey: Keys.lastHealthCheckAt) as? Date
  }

  func clearLastHealthCheckAt() {
    userDefaults?.removeObject(forKey: Keys.lastHealthCheckAt)
  }

  // MARK: - Reset All
  func resetAllData() {
    clearAction()
    clearNumbers()
    clearOrganizationAPIKey()
    clearLastHealthCheckAt()
  }
}
