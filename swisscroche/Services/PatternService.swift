import CoreData
import Foundation

/// Metadata about the official blocking list, extracted as plain Swift types
struct OfficialListMetadata {
  let name: String
  let version: String
  let blockedCount: Int
}

/// Service for managing Pattern entities in CoreData
class PatternService {
  private let dataStack = CoreDataStack.shared

  // MARK: - Create Operations

  /// Creates and saves a new pattern to CoreData
  /// - Parameters:
  ///   - patternString: The blocking pattern with '#' wildcards
  ///   - action: The action to take ("block", "identify", or "remove")
  ///   - name: Optional operator/source name
  ///   - source: The source of the pattern ("api" or "user")
  ///   - sourceListName: Optional list name from API
  ///   - sourceVersion: Optional list version from API
  /// - Returns: The created Pattern entity, or nil if creation fails
  func createPattern(
    patternString: String,
    action: String,
    name: String? = nil,
    source: String,
    sourceListName: String? = nil,
    sourceVersion: String? = nil
  ) async -> Pattern? {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        guard
          let entityDescription = NSEntityDescription.entity(forEntityName: "Pattern", in: context)
        else {
          Logger.error(
            "Failed to get Pattern entity description", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 1,
              userInfo: [NSLocalizedDescriptionKey: "Failed to get Pattern entity description"]))
          continuation.resume(returning: nil)
          return
        }

        guard
          let pattern = NSManagedObject(entity: entityDescription, insertInto: context) as? Pattern
        else {
          Logger.error(
            "Failed to cast NSManagedObject to Pattern", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 2,
              userInfo: [NSLocalizedDescriptionKey: "Failed to cast NSManagedObject to Pattern"]))
          continuation.resume(returning: nil)
          return
        }
        pattern.pattern = patternString
        pattern.action = action
        pattern.name = name
        pattern.source = source
        pattern.sourceListName = sourceListName
        pattern.sourceVersion = sourceVersion
        pattern.addedDate = Date()

        Self.save(context: context)
        continuation.resume(returning: pattern)
      }
    }
  }

  // MARK: - Read Operations

  /// Fetches all patterns from CoreData
  /// - Returns: Array of all Pattern entities
  private func getAllPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch all patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Fetches a pattern by its pattern string
  /// - Parameter pattern: The pattern string to search for
  /// - Returns: The matching Pattern entity, or nil if not found
  func getPattern(byPatternString pattern: String) async -> Pattern? {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "pattern == %@", pattern)
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let results = try context.fetch(fetchRequest)
          continuation.resume(returning: results.first)
        } catch {
          Logger.error(
            "Failed to fetch pattern %{public}@: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: nil)
        }
      }
    }
  }

  /// Fetches all patterns that have not been completed yet
  /// - Returns: Array of Pattern entities where completedDate is nil
  private func getPendingPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "completedDate == nil")
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch pending patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Fetches patterns by source
  /// - Parameter source: The source to filter by ("api" or "user")
  /// - Returns: Array of Pattern entities matching the source
  func getPatterns(bySource source: String) async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "source == %@", source)
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch patterns by source %{public}@: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Fetches metadata about the official blocking list entirely within the CoreData context
  /// - Returns: OfficialListMetadata with plain Swift types, or nil if no API patterns exist
  func getOfficialListMetadata() async -> OfficialListMetadata? {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "source == %@", "api")
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let patterns = try context.fetch(fetchRequest)
          guard let firstPattern = patterns.first else {
            continuation.resume(returning: nil)
            return
          }

          let name = firstPattern.sourceListName ?? "Liste Suisse"
          let version = firstPattern.sourceVersion ?? "1.0"
          let blockedCount = patterns.reduce(0) { total, pattern in
            guard let patternString = pattern.pattern else { return total }
            return total + Int(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
          }

          continuation.resume(
            returning: OfficialListMetadata(
              name: name, version: version, blockedCount: blockedCount))
        } catch {
          Logger.error(
            "Failed to fetch official list metadata: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: nil)
        }
      }
    }
  }

  /// Checks if any patterns exist in the database
  /// - Returns: true if at least one pattern exists, false otherwise
  func hasPatterns() async -> Bool {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.resultType = .countResultType

        do {
          let count = try context.count(for: fetchRequest)
          continuation.resume(returning: count > 0)
        } catch {
          Logger.error(
            "Failed to count patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: false)
        }
      }
    }
  }

  /// Retrieves a random pending pattern for processing
  /// - Returns: A random Pattern entity where completedDate is nil, or nil if none exist
  func retrievePatternForProcessing() async -> Pattern? {
    let pendingPatterns = await getPendingPatterns()
    return pendingPatterns.randomElement()
  }

  /// Fetches all patterns that have been completed
  /// - Returns: Array of Pattern entities where completedDate is not nil
  private func getCompletedPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "completedDate != nil")
        fetchRequest.returnsObjectsAsFaults = false

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch completed patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Counts the total number of phone numbers represented by all patterns in the database
  /// - Returns: Total count of phone numbers across all patterns
  func getTotalPhoneNumbersCount() async -> Int64 {
    let allPatterns = await getAllPatterns()
    return allPatterns.reduce(0) { total, pattern in
      guard let patternString = pattern.pattern else { return total }
      return total + Int64(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
    }
  }

  /// Gets the most recent completion date from all completed patterns
  /// - Returns: The most recent completedDate, or nil if no patterns are completed
  func getLastCompletionDate() async -> Date? {
    let completedPatterns = await getCompletedPatterns()
    return completedPatterns.compactMap { $0.completedDate }.max()
  }

  /// Counts the number of completed patterns
  /// - Returns: Count of patterns with completedDate != nil
  func getCompletedPatternsCount() async -> Int {
    return await getCompletedPatterns().count
  }

  /// Counts the number of pending patterns
  /// - Returns: Count of patterns with completedDate == nil
  func getPendingPatternsCount() async -> Int {
    return await getPendingPatterns().count
  }

  /// Counts the total number of phone numbers represented by pending patterns
  /// - Returns: Total count of phone numbers across patterns with completedDate == nil
  func getPendingPhoneNumbersCount() async -> Int64 {
    let pendingPatterns = await getPendingPatterns()
    return pendingPatterns.reduce(0) { total, pattern in
      guard let patternString = pattern.pattern else { return total }
      return total + PhoneNumberHelpers.countPhoneNumbers(for: patternString)
    }
  }

  /// Counts the total number of patterns (completed + pending)
  /// - Returns: Total count of all patterns
  func getTotalPatternsCount() async -> Int {
    return await getAllPatterns().count
  }

  // MARK: - Update Operations

  /// Updates an existing pattern
  /// - Parameters:
  ///   - pattern: The Pattern entity to update
  ///   - action: New action value (optional)
  ///   - name: New name value (optional)
  ///   - sourceListName: New sourceListName value (optional)
  ///   - sourceVersion: New sourceVersion value (optional)
  func updatePattern(
    _ pattern: Pattern,
    action: String? = nil,
    name: String? = nil,
    sourceListName: String? = nil,
    sourceVersion: String? = nil
  ) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        guard let patternInContext = context.object(with: objectID) as? Pattern else {
          Logger.error(
            "Failed to cast object to Pattern for update", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 3,
              userInfo: [NSLocalizedDescriptionKey: "Failed to cast object to Pattern"]))
          continuation.resume()
          return
        }
        if let action = action {
          patternInContext.action = action
        }
        if let name = name {
          patternInContext.name = name
        }
        if let sourceListName = sourceListName {
          patternInContext.sourceListName = sourceListName
        }
        if let sourceVersion = sourceVersion {
          patternInContext.sourceVersion = sourceVersion
        }

        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  /// Marks a pattern as completed
  /// - Parameter pattern: The Pattern entity to mark as completed
  func markPatternAsCompleted(_ pattern: Pattern) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        guard let patternInContext = context.object(with: objectID) as? Pattern else {
          Logger.error(
            "Failed to cast object to Pattern for completion", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 4,
              userInfo: [NSLocalizedDescriptionKey: "Failed to cast object to Pattern"]))
          continuation.resume()
          return
        }
        patternInContext.completedDate = Date()
        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  /// Marks a pattern for retry by setting completedDate slightly before the full reset cutoff,
  /// so it becomes eligible for reprocessing after patternRetryDelay.
  /// - Parameter pattern: The Pattern entity to mark for retry
  func markPatternForRetry(_ pattern: Pattern) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        guard let patternInContext = context.object(with: objectID) as? Pattern else {
          Logger.error(
            "Failed to cast object to Pattern for retry", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 6,
              userInfo: [NSLocalizedDescriptionKey: "Failed to cast object to Pattern"]))
          continuation.resume()
          return
        }
        patternInContext.completedDate = Calendar.current.date(
          byAdding: .day,
          value: -AppConstants.patternFullResetDays,
          to: Date()
        )!
        .addingTimeInterval(AppConstants.patternRetryDelay)
        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  /// Marks a pattern for deletion by changing its action and resetting completedDate
  /// - Parameter pattern: The Pattern entity to mark for deletion
  func markPatternForDeletion(_ pattern: Pattern) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        guard let patternInContext = context.object(with: objectID) as? Pattern else {
          Logger.error(
            "Failed to cast object to Pattern for deletion", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 5,
              userInfo: [NSLocalizedDescriptionKey: "Failed to cast object to Pattern"]))
          continuation.resume()
          return
        }
        let currentAction = patternInContext.action ?? "block"
        // Skip patterns already marked for removal
        if currentAction.hasPrefix("remove_") {
          continuation.resume()
          return
        }
        let removalAction = currentAction == "identify" ? "remove_identify" : "remove_block"
        patternInContext.action = removalAction
        patternInContext.completedDate = nil
        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  // MARK: - Delete Operations

  /// Deletes all patterns
  func deleteAllPatterns() async {
    let context = dataStack.persistentContainer.viewContext

    await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

        do {
          let patterns = try context.fetch(fetchRequest)
          for pattern in patterns {
            context.delete(pattern)
          }
          Self.save(context: context)
          continuation.resume()
        } catch {
          Logger.error(
            "Failed to delete all patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume()
        }
      }
    }
  }

  /// Resets completedDate to nil for ALL patterns completed more than patternFullResetDays ago
  /// Only affects "block" and "identify" actions (not removal actions)
  /// - Returns: The number of patterns that were reset
  func resetExpiredCompletedPatterns() async -> Int {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        let cutoffDate = Calendar.current.date(
          byAdding: .day,
          value: -AppConstants.patternFullResetDays,
          to: Date()
        )!
        fetchRequest.predicate = NSPredicate(
          format:
            "completedDate != nil AND completedDate < %@ AND (action == %@ OR action == %@)",
          cutoffDate as NSDate,
          "block",
          "identify"
        )

        do {
          let patterns = try context.fetch(fetchRequest)
          guard !patterns.isEmpty else {
            continuation.resume(returning: 0)
            return
          }
          for pattern in patterns {
            pattern.completedDate = nil
          }
          Self.save(context: context)
          continuation.resume(returning: patterns.count)
        } catch {
          Logger.error(
            "Failed to reset expired completed patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: 0)
        }
      }
    }
  }

  /// Deletes completed removal patterns (remove_block/remove_identify with completedDate != nil)
  /// These patterns have been successfully processed by the Call Directory extension and can be purged
  /// - Returns: The number of patterns that were deleted
  func deleteCompletedRemovalPatterns() async -> Int {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(
          format:
            "completedDate != nil AND (action == %@ OR action == %@)",
          "remove_block",
          "remove_identify"
        )

        do {
          let patterns = try context.fetch(fetchRequest)
          for pattern in patterns {
            context.delete(pattern)
          }
          Self.save(context: context)
          continuation.resume(returning: patterns.count)
        } catch {
          Logger.error(
            "Failed to delete completed removal patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: 0)
        }
      }
    }
  }

  /// Removes duplicate API patterns and user patterns that overlap with API patterns
  /// - Returns: A tuple (duplicatesRemoved, overlapsRemoved)
  func removeDuplicatePatterns() async -> (duplicatesRemoved: Int, overlapsRemoved: Int) {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        do {
          // Fetch all API patterns
          let apiFetch = NSFetchRequest<Pattern>(entityName: "Pattern")
          apiFetch.predicate = NSPredicate(format: "source == %@", "api")
          apiFetch.returnsObjectsAsFaults = false
          let apiPatterns = try context.fetch(apiFetch)

          // 1. Remove exact duplicates among API patterns (same pattern string)
          var duplicatesRemoved = 0
          var grouped: [String: [Pattern]] = [:]
          for pattern in apiPatterns {
            guard let patternString = pattern.pattern else { continue }
            grouped[patternString, default: []].append(pattern)
          }

          var keptApiPatterns: [Pattern] = []
          for (_, patterns) in grouped {
            // Keep the one with the most recent completedDate, or the first one
            let sorted = patterns.sorted { a, b in
              (a.completedDate ?? .distantPast) > (b.completedDate ?? .distantPast)
            }
            keptApiPatterns.append(sorted[0])
            for duplicate in sorted.dropFirst() {
              context.delete(duplicate)
              duplicatesRemoved += 1
            }
          }

          // 2. Remove user patterns that overlap with API patterns
          var overlapsRemoved = 0
          let userFetch = NSFetchRequest<Pattern>(entityName: "Pattern")
          userFetch.predicate = NSPredicate(
            format:
              "source == %@ AND action != %@ AND action != %@",
            "user", "remove_block", "remove_identify"
          )
          userFetch.returnsObjectsAsFaults = false
          let userPatterns = try context.fetch(userFetch)

          for userPattern in userPatterns {
            guard let userString = userPattern.pattern else { continue }
            let userPrefix = userString.replacingOccurrences(of: "#", with: "")
            let userLength = userString.count

            for apiPattern in keptApiPatterns {
              guard let apiString = apiPattern.pattern else { continue }
              let apiPrefix = apiString.replacingOccurrences(of: "#", with: "")
              let apiLength = apiString.count

              guard apiLength == userLength else { continue }

              if apiPrefix.hasPrefix(userPrefix) || userPrefix.hasPrefix(apiPrefix) {
                context.delete(userPattern)
                overlapsRemoved += 1
                break
              }
            }
          }

          Self.save(context: context)
          continuation.resume(returning: (duplicatesRemoved, overlapsRemoved))
        } catch {
          Logger.error(
            "Failed to remove duplicate patterns",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: (0, 0))
        }
      }
    }
  }

  /// Clears the completedDate on all patterns, making them pending again for reinstallation
  func clearAllCompletedDates() async {
    let context = dataStack.persistentContainer.viewContext

    await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

        do {
          let patterns = try context.fetch(fetchRequest)
          for pattern in patterns {
            pattern.completedDate = nil
          }
          Self.save(context: context)
          continuation.resume()
        } catch {
          Logger.error(
            "Failed to clear completed dates: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume()
        }
      }
    }
  }

  // MARK: - Private Methods

  /// Saves changes to the CoreData context.
  ///
  /// Saving with no persistent store loaded raises an Objective-C exception that `try`
  /// cannot catch, aborting the app — so the store is checked before writing rather
  /// than relying on the `catch` below.
  private static func save(context: NSManagedObjectContext) {
    guard context.hasChanges else { return }

    guard CoreDataStack.shared.isStoreLoaded else {
      Logger.error(
        "Skipping save: no persistent store is loaded",
        category: .patternService,
        error: CoreDataError.storeUnavailable
      )
      return
    }

    do {
      try context.save()
    } catch {
      Logger.error(
        "Failed to save context: %{public}@",
        category: .patternService,
        error: error
      )
    }
  }
}
