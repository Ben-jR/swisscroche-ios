import Foundation

/// Service for loading and managing MDM (Mobile Device Management) configuration
/// Reads Managed App Configuration from UserDefaults and extracts organization API key
class MDMConfigurationService {

  // MARK: - Constants

  private static let managedConfigKey = "com.apple.configuration.managed"
  private static let apiKeyKey = "api_key"

  // MARK: - Properties

  private let sharedUserDefaultsService: SharedUserDefaultsService

  // MARK: - Initialization

  init(sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService()) {
    self.sharedUserDefaultsService = sharedUserDefaultsService
  }

  // MARK: - Configuration Loading

  /// Loads MDM configuration and stores the API key if present
  /// - Returns: true if an API key was found and loaded, false otherwise
  @discardableResult
  func loadConfiguration() -> Bool {
    guard let managedConfig = UserDefaults.standard.dictionary(forKey: Self.managedConfigKey) else {
      Logger.info("No MDM configuration found", category: .mdm)
      return false
    }

    Logger.info("MDM configuration found", category: .mdm)

    // Extract API key from MDM configuration
    let apiKey = extractAPIKey(from: managedConfig)

    if let apiKey = apiKey {
      // Check if API key has changed
      let currentAPIKey = sharedUserDefaultsService.getOrganizationAPIKey()

      if currentAPIKey != apiKey {
        Logger.info("New organization API key detected via MDM", category: .mdm)
        // Store in SharedUserDefaults
        sharedUserDefaultsService.setOrganizationAPIKey(apiKey)

        // Trigger immediate health check with new API key
        HealthCheckService.shared.triggerHealthCheck()

        return true
      } else {
        Logger.info("Organization API key unchanged", category: .mdm)
      }
    } else {
      Logger.info("No organization API key in MDM configuration", category: .mdm)
      // If no API key in MDM, clear any existing one
      if sharedUserDefaultsService.getOrganizationAPIKey() != nil {
        sharedUserDefaultsService.clearOrganizationAPIKey()
        HealthCheckService.shared.triggerHealthCheck()
      }
    }

    return false
  }

  /// Extracts the API key from the MDM configuration dictionary
  /// - Parameter config: The MDM configuration dictionary
  /// - Returns: The API key string if found, nil otherwise
  private func extractAPIKey(from config: [String: Any]) -> String? {
    // Try both possible keys
    if let apiKey = config[Self.apiKeyKey] as? String {
      return apiKey
    }

    // Also try the key from AppConstants
    if let apiKey = config[AppConstants.SharedDefaultsKeys.organizationAPIKey] as? String {
      return apiKey
    }

    return nil
  }

  // MARK: - API Key Management

  /// Gets the current organization API key
  /// - Returns: The API key string if available, nil otherwise
  func getOrganizationAPIKey() -> String? {
    return sharedUserDefaultsService.getOrganizationAPIKey()
  }

  /// Checks if the app is in organization mode (has an API key)
  /// - Returns: true if an organization API key is configured, false otherwise
  func isOrganizationMode() -> Bool {
    return getOrganizationAPIKey() != nil
  }

  /// Clears the organization API key from SharedUserDefaults
  func clearOrganizationAPIKey() {
    sharedUserDefaultsService.clearOrganizationAPIKey()
    // Trigger health check to update with cleared API key
    HealthCheckService.shared.triggerHealthCheck()
  }
}
