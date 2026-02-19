import CoreData

/// Thread-safe CoreData stack with proper context management
class CoreDataStack: ObservableObject {
  static let shared = CoreDataStack()

  private init() {}

  // MARK: - Persistent Container

  /// The main persistent container, stored in App Group for extension access
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")

    guard
      let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)
    else {
      Logger.log(
        "Failed to get App Group container URL", category: .coreData, type: .fault)
      return container
    }

    let storeURL = containerURL.appendingPathComponent("DataModel.sqlite")

    let description = NSPersistentStoreDescription(url: storeURL)
    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores { _, error in
      if let error {
        // Attempt recovery by removing and recreating the store
        self.handlePersistentStoreError(error: error, storeURL: storeURL, container: container)
      }
    }
    return container
  }()

  /// Handle persistent store loading errors by attempting recovery
  private func handlePersistentStoreError(
    error: Error, storeURL: URL, container: NSPersistentContainer
  ) {
    Logger.log(
      "CoreData store failed to load: \(error.localizedDescription)",
      category: .coreData, type: .error)

    // Destroy the corrupted store and its auxiliary files (-wal, -shm)
    do {
      try container.persistentStoreCoordinator.destroyPersistentStore(
        at: storeURL, ofType: NSSQLiteStoreType, options: nil)
      Logger.log("Destroyed corrupted store at \(storeURL.path)", category: .coreData)
    } catch {
      Logger.log(
        "Failed to destroy corrupted store: \(error.localizedDescription)",
        category: .coreData, type: .error)
    }

    // Attempt to reload a fresh store
    container.loadPersistentStores { _, reloadError in
      if let reloadError {
        // Recovery failed — CoreData operations will not work in this session
        Logger.log(
          "Failed to reload store after recovery: \(reloadError.localizedDescription)",
          category: .coreData, type: .fault)
      } else {
        Logger.log("Successfully recovered with a fresh store", category: .coreData)
      }
    }
  }

  // MARK: - Background Context

  /// Private background context for off-main-thread operations
  private lazy var _backgroundContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    context.automaticallyMergesChangesFromParent = true
    return context
  }()

  // MARK: - Public Methods

  /// Get the view context (main thread only)
  func viewContext() -> NSManagedObjectContext {
    return persistentContainer.viewContext
  }

  /// Get a private background context for off-main-thread operations
  func backgroundContext() -> NSManagedObjectContext {
    return _backgroundContext
  }

  /// Perform a block on the view context
  func performOnViewContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
    viewContext().perform { [weak self] in
      block(
        self?.viewContext() ?? self?.persistentContainer.viewContext
          ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    }
  }

  /// Perform a block on the background context
  func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
    _backgroundContext.perform { [weak self] in
      block(
        self?._backgroundContext ?? self?.persistentContainer.newBackgroundContext()
          ?? NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
    }
  }

  /// Save changes in a context
  func saveContext(_ context: NSManagedObjectContext) throws {
    var saveError: Error?
    context.performAndWait {
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          saveError = error
        }
      }
    }

    if let saveError {
      throw saveError
    }
  }
}
