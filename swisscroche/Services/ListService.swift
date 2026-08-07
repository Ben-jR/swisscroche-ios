import CoreData
import Foundation

// MARK: - Block List Models

/// Shape of the block list JSON, both the copy bundled with the app and the published one.
///
/// `version` must be an ISO date (`YYYY-MM-DD`), because versions are compared as
/// strings to decide which of two lists is the newer one.
struct BlockList: Codable {
  let version: String
  let name: String
  let patterns: [BlockListPattern]

  /// Whether this list can be applied. Guards against a truncated download or a
  /// published file that would otherwise wipe every blocking rule.
  var isUsable: Bool {
    !version.isEmpty && !patterns.isEmpty
  }

  /// Whether this list supersedes `other`. Equal versions are not newer, so a
  /// list already applied is never reapplied.
  func isNewer(than other: BlockList) -> Bool {
    version.compare(other.version, options: .numeric) == .orderedDescending
  }
}

struct BlockListPattern: Codable {
  let name: String
  let action: String
  let pattern: String
}

/// Resolves which block list to use — published, cached or bundled — and syncs it into CoreData.
final class ListService {

  // MARK: - Dependencies

  private let userDefaultsService: UserDefaultsService
  private let patternService: PatternService
  private let remoteListService: RemoteListService

  // MARK: - Initialization

  init(
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    patternService: PatternService = PatternService(),
    remoteListService: RemoteListService = RemoteListService()
  ) {
    self.userDefaultsService = userDefaultsService
    self.patternService = patternService
    self.remoteListService = remoteListService
  }

  // MARK: - Public API

  /// Applies the best list already available on device — no network.
  ///
  /// Used at first launch and whenever the app starts, so a list shipped with a new
  /// app build takes effect immediately rather than waiting for the refresh window.
  func update() async throws {
    Logger.debug("Starting list update", category: .listService)
    let list = try bestLocalList()
    await apply(list)
  }

  /// Fetches the published list, then applies whichever available list is newest.
  ///
  /// A failed fetch is not an error: the device falls back to its cached copy, or to
  /// the bundled list.
  func refreshFromRemote() async throws {
    Logger.debug("Refreshing list from remote", category: .listService)

    let remote = await remoteListService.fetchList()
    userDefaultsService.setLastListDownloadAt(Date())

    var best = try bestLocalList()
    if let remote, remote.isNewer(than: best) {
      best = remote
    }
    await apply(best)
  }

  // MARK: - List Resolution

  /// The newest list available without networking: the cached download, or the
  /// bundled one when it is newer (a new app build can ship a newer list than the
  /// last one downloaded).
  private func bestLocalList() throws -> BlockList {
    let bundled = try loadBundledList()

    guard let cached = remoteListService.cachedList() else {
      return bundled
    }
    return cached.isNewer(than: bundled) ? cached : bundled
  }

  /// Applies a list to CoreData, skipping the work when that version is already applied.
  ///
  /// The stored version alone is not enough: if the patterns were wiped while the version
  /// stayed behind, the list has to be reapplied rather than skipped forever.
  private func apply(_ list: BlockList) async {
    let alreadyApplied = userDefaultsService.getAppliedListVersion() == list.version
    let hasListPatterns = await !patternService.getPatterns(bySource: "api").isEmpty

    guard !(alreadyApplied && hasListPatterns) else {
      Logger.debug(
        "List version \(list.version) already applied, nothing to do", category: .listService)
      return
    }

    await updateCoreData(list)
    userDefaultsService.setAppliedListVersion(list.version)
    Logger.info(
      "Applied list \"\(list.name)\" version \(list.version)", category: .listService)
  }

  /// Loads the block list bundled with the app (always available, no network)
  private func loadBundledList() throws -> BlockList {
    guard
      let url = Bundle.main.url(
        forResource: AppConstants.bundledListResourceName, withExtension: "json")
    else {
      throw ListServiceError.bundledListMissing
    }

    do {
      let data = try Data(contentsOf: url)
      let list = try JSONDecoder().decode(BlockList.self, from: data)
      guard list.isUsable else { throw ListServiceError.bundledListMissing }
      return list
    } catch let error as ListServiceError {
      throw error
    } catch {
      throw ListServiceError.loadFailed(error)
    }
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
