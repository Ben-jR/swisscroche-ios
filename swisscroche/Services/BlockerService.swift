import Foundation

/// Service for managing blocklist updates
final class BlockerService {

  /// Progress callback: (completedCount, totalCount)
  typealias PatternProgressCallback = @Sendable (Int, Int) async -> Void

  /// Pattern start callback: (patternString, action)
  typealias PatternStartCallback = @Sendable (String, String) async -> Void

  /// Number progress callback: (processedNumbersCount, totalNumbersCount)
  /// Reported after each processed chunk, so progress moves smoothly within large patterns
  typealias NumberProgressCallback = @Sendable (Int64, Int64) async -> Void

  // MARK: - Dependencies

  private let callDirectoryService: CallDirectoryService
  private let userDefaultsService: UserDefaultsService
  private let listService: ListService
  private let patternService: PatternService
  private let sharedUserDefaultsService: SharedUserDefaultsService

  // MARK: - Initialization

  init(
    callDirectoryService: CallDirectoryService = CallDirectoryService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    listService: ListService = ListService(),
    patternService: PatternService = PatternService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService()
  ) {
    self.callDirectoryService = callDirectoryService
    self.userDefaultsService = userDefaultsService
    self.listService = listService
    self.patternService = patternService
    self.sharedUserDefaultsService = sharedUserDefaultsService
  }

  // MARK: - iOS Version

  /// Checks if the iOS version has changed since the last known version was stored
  func hasIOSVersionChanged() -> Bool {
    let currentVersion = ProcessInfo.processInfo.operatingSystemVersionString
    let storedVersion = userDefaultsService.getLastKnownIOSVersion()
    return storedVersion != nil && storedVersion != currentVersion
  }

  // MARK: - Extension Management

  /// Checks the current status of the Call Directory extension
  func checkExtensionStatus() async throws -> BlockerExtensionStatus {
    try await callDirectoryService.checkExtensionStatus()
  }

  /// Opens the app's settings page
  func openSettings() async throws {
    try await callDirectoryService.openSettings()
  }

  /// Resets the Call Directory extension state and invalidates all patterns
  func resetExtensionState() async {
    sharedUserDefaultsService.setAction("reset")
    sharedUserDefaultsService.setNumbers([])
    do {
      try await callDirectoryService.reloadExtension()
    } catch {
      Logger.error(
        "Failed to reload extension during reset, continuing anyway",
        category: .blockerService, error: error)
    }
    await patternService.clearAllCompletedDates()
    userDefaultsService.clearLastSuccessfulUpdateAt()
  }

  // MARK: - Download

  /// Downloads the list from the API and updates the timestamp
  private func downloadList() async throws {
    Logger.debug("Downloading list", category: .blockerService)
    do {
      try await listService.update()
    } catch {
      throw BlockerServiceError.listUpdateFailed(error)
    }
  }

  /// Downloads the list only if it is stale (>24h)
  func downloadListIfStale() async throws {
    if userDefaultsService.shouldUpdateList() {
      Logger.debug("List is stale, downloading", category: .blockerService)
      try await downloadList()
    }
  }

  // MARK: - Update

  /// Performs a background update: downloads list if stale, then processes pending patterns
  func performBackgroundUpdate() async throws {
    Logger.debug("performBackgroundUpdate called", category: .blockerService)
    try await handleFirstLaunch()
    await resetPatternsIfNeeded()
    await cleanupDuplicatePatterns()
    try await downloadListIfStale()
    try await processPendingPatterns()
    await deleteCompletedRemovalPatterns()
    userDefaultsService.setLastSuccessfulUpdateAt(Date())
  }

  /// Performs a foreground update: checks iOS version, then processes pending patterns with progress callback
  func performForegroundUpdate(
    onPatternStarted: PatternStartCallback? = nil,
    onPatternCompleted: PatternProgressCallback? = nil,
    onNumbersProgress: NumberProgressCallback? = nil
  ) async throws {
    Logger.debug("performForegroundUpdate called", category: .blockerService)
    try await handleFirstLaunch()
    await resetPatternsIfNeeded()
    await cleanupDuplicatePatterns()
    try await processPendingPatterns(
      onPatternStarted: onPatternStarted,
      onPatternCompleted: onPatternCompleted,
      onNumbersProgress: onNumbersProgress
    )
    await deleteCompletedRemovalPatterns()
    userDefaultsService.setLastSuccessfulUpdateAt(Date())
  }

  /// Resets patterns based on iOS version change or expiration
  /// - If iOS version changed: resets ALL patterns (completedDate = nil)
  /// - Otherwise: resets only expired completed patterns (percentage-based)
  /// Always saves the current iOS version
  private func resetPatternsIfNeeded() async {
    let currentVersion = ProcessInfo.processInfo.operatingSystemVersionString
    let hasVersionChanged = hasIOSVersionChanged()

    if hasVersionChanged {
      // iOS version changed: reset ALL patterns for reprocessing
      await patternService.clearAllCompletedDates()
      Logger.debug(
        "iOS version changed to \(currentVersion), reset all patterns for reprocessing",
        category: .blockerService)
    } else {
      // Normal case: reset only expired patterns
      let resetCount = await patternService.resetExpiredCompletedPatterns()
      if resetCount > 0 {
        Logger.debug(
          "Reset \(resetCount) expired completed patterns",
          category: .blockerService)
      }
    }

    // Always save the current version
    userDefaultsService.setLastKnownIOSVersion(currentVersion)
  }

  /// Removes duplicate API patterns and user patterns that overlap with API patterns
  private func cleanupDuplicatePatterns() async {
    let result = await patternService.removeDuplicatePatterns()
    if result.duplicatesRemoved > 0 || result.overlapsRemoved > 0 {
      Logger.debug(
        "Cleanup: \(result.duplicatesRemoved) duplicates, \(result.overlapsRemoved) overlaps removed",
        category: .blockerService)
    }
  }

  /// Deletes completed removal patterns
  private func deleteCompletedRemovalPatterns() async {
    let deletedCount = await patternService.deleteCompletedRemovalPatterns()
    if deletedCount > 0 {
      Logger.debug(
        "Deleted \(deletedCount) completed removal patterns", category: .blockerService)
    }
  }

  /// Processes all pending patterns
  private func processPendingPatterns(
    onPatternStarted: PatternStartCallback? = nil,
    onPatternCompleted: PatternProgressCallback? = nil,
    onNumbersProgress: NumberProgressCallback? = nil
  ) async throws {
    let totalCount = await patternService.getPendingPatternsCount()
    var totalNumbersCount = await patternService.getPendingPhoneNumbersCount()
    guard totalCount > 0 && totalNumbersCount > 0 else {
      Logger.debug(
        "No pending items to process: patterns=\(totalCount), numbers=\(totalNumbersCount)",
        category: .blockerService)
      return
    }

    Logger.debug("Pending patterns found: \(totalCount)", category: .blockerService)
    var completedCount = 0
    var processedNumbersCount: Int64 = 0

    while true {
      try Task.checkCancellation()

      guard let pattern = await patternService.retrievePatternForProcessing(),
        let patternString = pattern.pattern
      else { break }

      await onPatternStarted?(patternString, pattern.action ?? "block")

      let patternNumbersCount = PhoneNumberHelpers.countPhoneNumbers(for: patternString)
      var patternProcessedNumbersCount: Int64 = 0

      do {
        try await processPendingPattern(pattern) { chunkNumbersCount in
          patternProcessedNumbersCount += Int64(chunkNumbersCount)
          processedNumbersCount += Int64(chunkNumbersCount)
          await onNumbersProgress?(processedNumbersCount, totalNumbersCount)
        }
      } catch is CancellationError {
        throw CancellationError()
      } catch {
        Logger.error(
          "Pattern '\(patternString)' failed, retrying later",
          category: .blockerService, error: error)
        await patternService.markPatternForRetry(pattern)
        // Exclude the failed pattern from progress so remaining work stays accurate
        processedNumbersCount -= patternProcessedNumbersCount
        totalNumbersCount -= patternNumbersCount
        await onNumbersProgress?(processedNumbersCount, totalNumbersCount)
        continue
      }

      completedCount += 1
      await onPatternCompleted?(completedCount, totalCount)
    }
  }

  /// Handles first launch scenario
  private func handleFirstLaunch() async throws {
    let hasPatterns = await patternService.hasPatterns()
    if !hasPatterns {
      Logger.debug("No patterns found, launching update", category: .blockerService)
      try await downloadList()
    }
  }

  // MARK: - Reset

  /// Resets the entire application: cancels notifications, deletes all data, and exits
  func resetApplication(notificationService: NotificationService) async {
    notificationService.cancelReminderNotification()
    await patternService.deleteAllPatterns()
    userDefaultsService.resetAllData()
    sharedUserDefaultsService.resetAllData()
    sharedUserDefaultsService.setAction("reset")
    sharedUserDefaultsService.setNumbers([])
    do {
      try await callDirectoryService.reloadExtension()
    } catch {
      Logger.error(
        "Failed to reload extension during reset",
        category: .blockerService, error: error)
    }
  }

  // MARK: - Private Helpers

  /// Processes a specific pending pattern
  private func processPendingPattern(
    _ pattern: Pattern,
    onNumbersProgress: ((Int) async -> Void)? = nil
  ) async throws {
    try Task.checkCancellation()

    let patternString = pattern.pattern ?? ""
    Logger.debug("Processing pattern: \(patternString)", category: .blockerService)

    let numbers = PhoneNumberHelpers.expandBlockingPattern(patternString)
    let chunkSize = AppConstants.numberChunkSize
    let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map {
      Array(numbers[$0..<min($0 + chunkSize, numbers.count)])
    }

    try await processChunks(chunks, for: pattern, onNumbersProgress: onNumbersProgress)
    Logger.debug("Completed pattern: \(patternString)", category: .blockerService)
    await patternService.markPatternAsCompleted(pattern)
  }

  /// Process chunks iteratively: removes then adds numbers for each chunk
  private func processChunks(
    _ chunks: [[String]],
    for pattern: Pattern,
    onNumbersProgress: ((Int) async -> Void)? = nil
  ) async throws {
    let currentAction = pattern.action ?? "block"
    let isRemovalAction = currentAction.hasPrefix("remove_")
    let removalAction = currentAction == "identify" ? "remove_identify" : "remove_block"

    for chunk in chunks {
      try Task.checkCancellation()

      let numbersData = chunk.map { ["number": $0, "name": pattern.name ?? ""] }

      if !isRemovalAction {
        sharedUserDefaultsService.setAction(removalAction)
        sharedUserDefaultsService.setNumbers(numbersData)

        do {
          try await callDirectoryService.reloadExtension()
        } catch is CancellationError {
          throw CancellationError()
        } catch  where Task.isCancelled {
          throw CancellationError()
        } catch {
          Logger.debug(
            "Removal before add failed for chunk (numbers likely absent), continuing",
            category: .blockerService
          )
        }

        try Task.checkCancellation()
      }

      sharedUserDefaultsService.setAction(currentAction)
      sharedUserDefaultsService.setNumbers(numbersData)

      do {
        try await callDirectoryService.reloadExtension()
      } catch is CancellationError {
        throw CancellationError()
      } catch  where Task.isCancelled {
        throw CancellationError()
      } catch {
        Logger.error(
          "Failed to reload extension for chunk",
          category: .blockerService,
          error: error
        )
        throw BlockerServiceError.extensionReloadFailed(error)
      }

      await onNumbersProgress?(chunk.count)
    }
  }
}
