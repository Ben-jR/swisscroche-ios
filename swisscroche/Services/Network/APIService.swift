import Foundation

/// Base API service
class APIService {
  let session: URLSession

  var jsonHeaders: [String: String] {
    [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]
  }

  var deviceIdentifier: String {
    return UserDefaultsService().getOrCreateDeviceIdentifier()
  }

  // Organization API key for MDM-managed devices
  private var customAPIKey: String?

  var apiKey: String? {
    return customAPIKey ?? SharedUserDefaultsService().getOrganizationAPIKey()
  }

  init(configuration: URLSessionConfiguration = .default) {
    self.customAPIKey = nil
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  /// Initializer with optional API key (for testing or dependency injection)
  init(apiKey: String?, configuration: URLSessionConfiguration = .default) {
    self.customAPIKey = apiKey
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  func makeRequest(url: URL, method: HTTPMethod) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    jsonHeaders.forEach { field, value in
      request.setValue(value, forHTTPHeaderField: field)
    }
    request.setValue(deviceIdentifier, forHTTPHeaderField: "X-Device-ID")
    request.setValue("FR", forHTTPHeaderField: "X-Country-Code")

    // Add X-API-Key header if organization API key is available
    if let apiKey = self.apiKey, !apiKey.isEmpty {
      request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }

    return request
  }

  func performRequest(_ request: URLRequest) async throws -> Data {
    do {
      let (data, response) = try await session.data(for: request)
      try handleHTTPResponse(response, data: data)
      return data
    } catch {
      throw mapNetworkError(error)
    }
  }

  func handleHTTPResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else { return }

    switch httpResponse.statusCode {
    case 200...299:
      return  // Success, no action needed
    case 300...399:
      throw NetworkError.serverError(httpResponse.statusCode, "Unexpected redirect")
    case 400...499, 500...599:
      let errorMessage = extractErrorMessage(from: data)
      throw NetworkError.serverError(httpResponse.statusCode, errorMessage)
    default:
      throw NetworkError.serverError(httpResponse.statusCode, nil)
    }
  }

  func mapNetworkError(_ error: Error) -> NetworkError {
    if let networkError = error as? NetworkError {
      return networkError
    }

    let nsError = error as NSError
    switch nsError.code {
    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
      return .networkUnavailable
    case NSURLErrorTimedOut:
      return .timeout
    default:
      return .unknown
    }
  }

  func extractErrorMessage(from data: Data) -> String? {
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      if let message = json["message"] as? String {
        return message
      }
      if let error = json["error"] as? String {
        return error
      }
      if let detail = json["detail"] as? String {
        return detail
      }
    }

    if let text = String(data: data, encoding: .utf8), !text.isEmpty {
      return text
    }

    return nil
  }
}
