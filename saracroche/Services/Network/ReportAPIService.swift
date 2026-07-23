import Foundation

/// Service for reporting unwanted calls
class ReportAPIService: APIService {
  /// Initialize ReportAPIService
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Report unwanted phone number to v1 API
  /// - Parameters:
  ///   - phone: The phone number to report
  ///   - isGood: Whether the number is legitimate (true) or spam (false)
  func report(_ phone: Int64, isGood: Bool = false) async throws {
    guard let url = URL(string: AppConstants.apiReportURL) else {
      throw NetworkError.invalidURL
    }

    let requestData = ReportRequest(phone: phone, is_good: isGood)
    let jsonData = try JSONEncoder().encode(requestData)

    var request = makeRequest(url: url, method: .post)
    request.httpBody = jsonData

    _ = try await performRequest(request)
  }

  /// Report unwanted phone number to v2 API (requires organization API key)
  /// - Parameters:
  ///   - phone: The phone number to report
  ///   - isGood: Whether the number is legitimate (true) or spam (false)
  func reportToV2(_ phone: Int64, isGood: Bool = false) async throws {
    guard let url = URL(string: AppConstants.apiReportsURLV2) else {
      throw NetworkError.invalidURL
    }

    let requestData = ReportRequest(phone: phone, is_good: isGood)
    let jsonData = try JSONEncoder().encode(requestData)

    var request = makeRequest(url: url, method: .post)
    request.httpBody = jsonData

    _ = try await performRequest(request)
  }
}

private struct ReportRequest: Codable {
  let phone: Int64
  let is_good: Bool
}
