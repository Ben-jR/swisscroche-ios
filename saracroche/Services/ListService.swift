import CoreData
import Foundation

// MARK: - API Response Models

struct APIListResponse: Codable {
  let version: String
  let name: String
  let patterns: [APIPattern]
}

struct APIPattern: Codable {
  let name: String
  let action: String
  let pattern: String
}

/// Service for managing block lists - downloading, converting, and processing
final class ListService {

  // MARK: - Dependencies

  private let listAPIService: ListAPIService
  private let userDefaultsService: UserDefaultsService
  private let patternService: PatternService

  // MARK: - Initialization

  init(
    listAPIService: ListAPIService = ListAPIService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    patternService: PatternService = PatternService()
  ) {
    self.listAPIService = listAPIService
    self.userDefaultsService = userDefaultsService
    self.patternService = patternService
  }

  // MARK: - Public API

  /// Download and update the French block list
  func update() async throws {
    Logger.debug("Starting list update", category: .listService)

    do {
      let jsonResponse = try await listAPIService.downloadFrenchList()
      let apiResponse = try decodeListResponse(jsonResponse)
      await updateCoreData(apiResponse)
      userDefaultsService.setLastListDownloadAt(Date())
      Logger.info("List update completed successfully", category: .listService)
    } catch {
      Logger.error("Failed to download blocklist", category: .listService, error: error)
      throw ListServiceError.downloadFailed(error)
    }
  }

  private func decodeListResponse(_ json: [String: Any]) throws -> APIListResponse {
    let jsonData = try JSONSerialization.data(withJSONObject: json)
    return try JSONDecoder().decode(APIListResponse.self, from: jsonData)
  }

  /// Convert list from API response to CoreData
  private func updateCoreData(_ apiResponse: APIListResponse) async {
    let newPatternStrings: Set<String> = Set(apiResponse.patterns.map { $0.pattern })
    let existingPatterns = await patternService.getPatterns(bySource: "api")

    Logger.info(
      "Starting updateCoreData - Found \(apiResponse.patterns.count) patterns in API response",
      category: .listService)
    Logger.info("Existing patterns in CoreData: \(existingPatterns.count)", category: .listService)

    var removedCount = 0
    var updatedCount = 0
    var addedCount = 0

    // Create a dictionary of existing patterns for efficient lookup
    // This avoids calling getPattern(by:) during enumeration which can cause conflicts
    // Using uniquingKeysWith to handle potential duplicate pattern strings safely
    let existingPatternsDict = Dictionary(
      existingPatterns.compactMap { pattern -> (String, Pattern)? in
        guard let patternString = pattern.pattern else { return nil }
        return (patternString, pattern)
      },
      uniquingKeysWith: { first, _ in first }
    )

    // Find patterns to remove (those no longer in the new list)
    let patternsToRemove = existingPatternsDict.keys.filter { !newPatternStrings.contains($0) }

    // Mark patterns that are no longer in the new list for removal
    for patternString in patternsToRemove {
      if let pattern = existingPatternsDict[patternString] {
        await patternService.markPatternForDeletion(pattern)
        removedCount += 1
      }
    }

    // Add or update patterns from the API response
    for newPattern in apiResponse.patterns {
      if let existingPattern = existingPatternsDict[newPattern.pattern] {
        await patternService.updatePattern(
          existingPattern,
          action: newPattern.action,
          name: newPattern.name,
          sourceListName: apiResponse.name,
          sourceVersion: apiResponse.version
        )
        updatedCount += 1
      } else {
        _ = await patternService.createPattern(
          patternString: newPattern.pattern,
          action: newPattern.action,
          name: newPattern.name,
          source: "api",
          sourceListName: apiResponse.name,
          sourceVersion: apiResponse.version
        )
        addedCount += 1
      }
    }

    Logger.info(
      "updateCoreData completed - Added: \(addedCount), Updated: \(updatedCount), Removed: \(removedCount)",
      category: .listService
    )
  }
}
