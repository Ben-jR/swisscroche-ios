import CoreData
import OSLog

private let logger = Logger(
  subsystem: "ch.swisscroche.app.filter", category: "MessageFilterService")

/// Service responsible for checking incoming SMS senders against blocking patterns
final class MessageFilterService {

  /// Checks if a sender should be filtered based on stored blocking patterns
  /// - Parameter sender: The phone number or identifier of the SMS sender
  /// - Returns: `true` if the sender matches a blocking pattern
  func shouldFilter(sender: String) -> Bool {
    let context = Self.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pattern")

    do {
      let patterns = try context.fetch(fetchRequest)
      for patternObject in patterns {
        guard let pattern = patternObject.value(forKey: "pattern") as? String else {
          continue
        }
        if PhoneNumberHelpers.matches(number: sender, pattern: pattern) {
          logger.info("Sender \(sender, privacy: .private) matched pattern \(pattern)")
          return true
        }
      }
    } catch {
      logger.error("Failed to fetch patterns: \(error.localizedDescription)")
    }

    return false
  }

  // MARK: - CoreData Stack (read-only, lightweight)

  private static let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: AppConstants.coreDataModelName)

    guard
      let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)
    else {
      logger.fault("Failed to get App Group container URL")
      return container
    }

    let storeURL = containerURL.appendingPathComponent(AppConstants.coreDataStoreFilename)

    let description = NSPersistentStoreDescription(url: storeURL)
    description.isReadOnly = true
    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores { _, error in
      if let error {
        logger.error("Failed to load persistent stores: \(error.localizedDescription)")
      }
    }
    return container
  }()
}
