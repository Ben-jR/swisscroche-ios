import Foundation

/// Service for downloading block lists
class ListAPIService: APIService {

  /// Download French block list from v1 API
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

  /// Download lists from v2 API (requires organization API key)
  /// - Parameter listName: The name of the list to download
  /// - Returns: The list data as [String: Any]
  func downloadList(fromV2 listName: String) async throws -> [String: Any] {
    let urlString = "\(AppConstants.apiListsURL)/\(listName)"
    guard let url = URL(string: urlString) else {
      throw NetworkError.invalidURL
    }

    let request = makeRequest(url: url, method: .get)
    let data = try await performRequest(request)

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
