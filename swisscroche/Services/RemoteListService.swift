import Foundation

/// Fetches the published block list.
///
/// Deliberately minimal: an anonymous GET of a static public file, on an ephemeral
/// session so nothing is persisted to a shared cookie or credential store. No device
/// identifier, no custom headers, no telemetry — the request carries nothing that
/// distinguishes one user from another.
///
/// The result is cached in the App Group container so a later launch keeps the newest
/// known list even with no connectivity.
final class RemoteListService {

  private let session: URLSession
  private let urlString: String

  init(urlString: String = AppConstants.remoteListURL) {
    self.urlString = urlString

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = AppConstants.remoteListRequestTimeout
    configuration.timeoutIntervalForResource = AppConstants.remoteListRequestTimeout
    configuration.httpCookieAcceptPolicy = .never
    configuration.httpShouldSetCookies = false
    configuration.allowsCellularAccess = true
    self.session = URLSession(configuration: configuration)
  }

  // MARK: - Fetch

  /// Downloads and decodes the published list.
  /// - Returns: The decoded list, or `nil` when it cannot be fetched or parsed.
  ///   A failure here is never fatal — the caller falls back to the bundled list.
  func fetchList() async -> BlockList? {
    guard let url = URL(string: urlString) else {
      Logger.error(
        "Invalid remote list URL", category: .listService,
        error: ListServiceError.invalidRemoteURL)
      return nil
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      let (data, response) = try await session.data(for: request)

      if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
        Logger.error(
          "Remote list returned HTTP \(http.statusCode)", category: .listService,
          error: ListServiceError.remoteUnavailable)
        return nil
      }

      let list = try JSONDecoder().decode(BlockList.self, from: data)
      guard list.isUsable else {
        Logger.error(
          "Remote list rejected: empty or malformed", category: .listService,
          error: ListServiceError.remoteListInvalid)
        return nil
      }

      cache(data)
      Logger.info("Fetched remote list version \(list.version)", category: .listService)
      return list
    } catch {
      Logger.error("Failed to fetch remote list", category: .listService, error: error)
      return nil
    }
  }

  // MARK: - Cache

  private var cacheURL: URL? {
    FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)?
      .appendingPathComponent(AppConstants.remoteListCacheFilename)
  }

  private func cache(_ data: Data) {
    guard let cacheURL else { return }
    do {
      try data.write(to: cacheURL, options: .atomic)
    } catch {
      // A failed cache write only costs us the offline copy.
      Logger.error("Failed to cache remote list", category: .listService, error: error)
    }
  }

  /// The newest list previously fetched, if any.
  func cachedList() -> BlockList? {
    guard let cacheURL, FileManager.default.fileExists(atPath: cacheURL.path) else { return nil }
    do {
      let data = try Data(contentsOf: cacheURL)
      let list = try JSONDecoder().decode(BlockList.self, from: data)
      return list.isUsable ? list : nil
    } catch {
      Logger.error("Failed to read cached remote list", category: .listService, error: error)
      return nil
    }
  }

  /// Removes the cached copy, so the app falls back to the bundled list.
  func clearCache() {
    guard let cacheURL else { return }
    try? FileManager.default.removeItem(at: cacheURL)
  }
}
