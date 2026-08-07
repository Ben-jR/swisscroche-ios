import Foundation

/// Service for reporting unwanted calls
class ReportAPIService: APIService {
  /// Initialize ReportAPIService
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Report unwanted phone number to v2 API
  /// - Parameters:
  ///   - phone: The phone number to report (E.164 format string)
  ///   - isGood: Whether the number is legitimate (true) or spam (false)
  func report(_ phone: String, isGood: Bool = false) async throws {
    guard let url = URL(string: AppConstants.apiReportsURL) else {
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
  let phone: String
  let is_good: Bool
}
