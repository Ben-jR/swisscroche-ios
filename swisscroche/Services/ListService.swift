import CoreData
import Foundation

// MARK: - Bundled List Models

/// Shape of the block list JSON bundled with the app
struct BlockList: Codable {
  let version: String
  let name: String
  let patterns: [BlockListPattern]
}

struct BlockListPattern: Codable {
  let name: String
  let action: String
  let pattern: String
}

/// Loads the bundled block list and syncs it into CoreData
final class ListService {

  // MARK: - Dependencies

  private let userDefaultsService: UserDefaultsService
  private let patternService: PatternService

  // MARK: - Initialization

  init(
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    patternService: PatternService = PatternService()
  ) {
    self.userDefaultsService = userDefaultsService
    self.patternService = patternService
  }

  // MARK: - Public API

  /// Load and apply the bundled Swiss block list
  func update() async throws {
    Logger.debug("Starting list update", category: .listService)

    do {
      let list = try loadBundledSwissList()
      await updateCoreData(list)
      userDefaultsService.setLastListDownloadAt(Date())
      Logger.info("List update completed successfully", category: .listService)
    } catch {
      Logger.error("Failed to load blocklist", category: .listService, error: error)
      throw ListServiceError.loadFailed(error)
    }
  }

  /// Loads the Swiss block list bundled with the app (no network dependency)
  private func loadBundledSwissList() throws -> BlockList {
    guard
      let url = Bundle.main.url(
        forResource: AppConstants.bundledListResourceName, withExtension: "json")
    else {
      throw ListServiceError.bundledListMissing
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(BlockList.self, from: data)
  }

  /// Sync the bundled list into CoreData
  private func updateCoreData(_ list: BlockList) async {
    let newPatternStrings: Set<String> = Set(list.patterns.map { $0.pattern })
    let existingPatterns = await patternService.getPatterns(bySource: "api")

    Logger.info(
      "Starting updateCoreData - Found \(list.patterns.count) patterns in bundled list",
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

    // Add or update patterns from the bundled list
    for newPattern in list.patterns {
      if let existingPattern = existingPatternsDict[newPattern.pattern] {
        await patternService.updatePattern(
          existingPattern,
          action: newPattern.action,
          name: newPattern.name,
          sourceListName: list.name,
          sourceVersion: list.version
        )
        updatedCount += 1
      } else {
        _ = await patternService.createPattern(
          patternString: newPattern.pattern,
          action: newPattern.action,
          name: newPattern.name,
          source: "api",
          sourceListName: list.name,
          sourceVersion: list.version
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
