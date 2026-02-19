import Foundation

/// Service for downloading block lists
class ListAPIService: APIService {

  /// Download French block list
  func downloadFrenchList() async throws -> [String: Any] {
    guard let url = URL(string: AppConstants.apiFrenchListURL) else {
      throw NetworkError.invalidURL
    }

    let request = makeRequest(url: url, method: .get)
    let data = try await performRequest(request)

    // Parse the JSON data with proper error propagation
    do {
      guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NetworkError.decodingError
      }
      return json
    } catch let error as NetworkError {
      throw error
    } catch {
      throw NetworkError.decodingError
    }
  }
}
