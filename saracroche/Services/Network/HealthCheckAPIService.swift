import Foundation

/// Service for sending health check requests to the API
class HealthCheckAPIService: APIService {

  /// Singleton instance for convenience
  static let shared = HealthCheckAPIService()

  /// Send a health check request to the server
  /// - Returns: Void on success
  /// - Throws: NetworkError on failure
  func sendHealthCheck() async throws {
    guard let url = URL(string: AppConstants.apiHealthCheckURL) else {
      throw NetworkError.invalidURL
    }

    Logger.info("Sending health check request", category: .healthCheck)

    let request = makeRequest(url: url, method: .post)

    do {
      let _ = try await performRequest(request)
      Logger.info("Health check succeeded", category: .healthCheck)
    } catch {
      Logger.error("Health check failed", category: .healthCheck, error: error)
      throw error
    }
  }

  /// Send a health check request with explicit API key (for testing)
  /// - Parameter apiKey: The API key to use
  /// - Returns: Void on success
  /// - Throws: NetworkError on failure
  func sendHealthCheck(with apiKey: String) async throws {
    // Create a new instance with the custom API key
    let service = HealthCheckAPIService(apiKey: apiKey)
    try await service.sendHealthCheck()
  }
}
