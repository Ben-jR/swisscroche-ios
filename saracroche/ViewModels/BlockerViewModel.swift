import SwiftUI

/// View model for pattern statistics, update orchestration, and dates
@MainActor
class BlockerUpdateViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var updateState: BlockerUpdateStatus = .ok
  @Published var lastSuccessfulUpdateAt: Date? = nil

  // Statistics for blocked numbers
  @Published var totalPhoneNumbersCount: Int64 = 0
  @Published var completedPatternsCount: Int = 0
  @Published var pendingPatternsCount: Int = 0
  @Published var totalPatternsCount: Int = 0
  @Published var lastListDownloadAt: Date? = nil
  @Published var lastBackgroundLaunchAt: Date? = nil

  @Published var shouldUpdateList: Bool = false
  @Published var iosVersionChanged: Bool = false
  @Published var isCancellationRequested: Bool = false
  @Published var showUpdateError: Bool = false

  // Current pattern being processed
  @Published var currentPatternString: String? = nil
  @Published var currentPatternAction: String? = nil

  // Estimated time remaining for the current update, in seconds
  @Published var estimatedTimeRemaining: TimeInterval? = nil

  // MARK: - Private Properties

  private var updateStartedAt: Date? = nil

  // MARK: - Dependencies

  private let userDefaults: UserDefaultsService
  private let blockerService: BlockerService
  private let patternService: PatternService
  private let notificationService: NotificationService

  // MARK: - Initialization

  init(
    userDefaults: UserDefaultsService = UserDefaultsService(),
    blockerService: BlockerService = BlockerService(),
    patternService: PatternService = PatternService(),
    notificationService: NotificationService? = nil
  ) {
    self.userDefaults = userDefaults
    self.blockerService = blockerService
    self.patternService = patternService
    self.notificationService =
      notificationService ?? NotificationService(userDefaults: userDefaults)
  }

  // MARK: - Data Loading

  func loadData() async {
    lastSuccessfulUpdateAt = userDefaults.getLastSuccessfulUpdateAt()
    lastListDownloadAt = userDefaults.getLastListDownloadAt()
    lastBackgroundLaunchAt = userDefaults.getLastBackgroundLaunchAt()

    totalPhoneNumbersCount = await patternService.getTotalPhoneNumbersCount()
    completedPatternsCount = await patternService.getCompletedPatternsCount()
    pendingPatternsCount = await patternService.getPendingPatternsCount()
    totalPatternsCount = await patternService.getTotalPatternsCount()

    shouldUpdateList = userDefaults.shouldUpdateList()
    iosVersionChanged = blockerService.hasIOSVersionChanged()
  }

  // MARK: - List Download

  /// Downloads the list silently on app launch and refreshes counters
  func downloadListOnLaunch() async {
    do {
      try await blockerService.downloadListIfStale()
      pendingPatternsCount = await patternService.getPendingPatternsCount()
      completedPatternsCount = await patternService.getCompletedPatternsCount()
      totalPhoneNumbersCount = await patternService.getTotalPhoneNumbersCount()
      shouldUpdateList = userDefaults.shouldUpdateList()
      lastListDownloadAt = userDefaults.getLastListDownloadAt()
    } catch {
      Logger.error(
        "Silent list download on launch failed", category: .blockerViewModel, error: error)
    }
  }

  // MARK: - Update Management

  /// Performs update with state management
  func performUpdateWithStateManagement() async {
    // Set starting state
    updateState = .inProgress(progress: 0.0)
    isCancellationRequested = false
    estimatedTimeRemaining = nil
    updateStartedAt = Date()

    // Calculate total patterns count at the start for progress tracking
    totalPatternsCount = completedPatternsCount + pendingPatternsCount

    do {
      try await blockerService.performForegroundUpdate(
        onPatternStarted: { [weak self] patternString, action in
          guard let self = self else { return }
          await MainActor.run {
            self.currentPatternString = patternString
            self.currentPatternAction = action
          }
        },
        onPatternCompleted: { [weak self] completedCount, totalCount in
          guard let self = self else { return }
          await MainActor.run {
            self.completedPatternsCount = completedCount
            self.totalPatternsCount = totalCount
          }
        },
        onNumbersProgress: { [weak self] processedNumbers, totalNumbers in
          guard let self = self else { return }
          await MainActor.run {
            self.handleNumbersProgress(
              processedNumbers: processedNumbers,
              totalNumbers: totalNumbers
            )
          }
        }
      )
    } catch is CancellationError {
      Logger.debug("Update task cancelled", category: .blockerViewModel)
      currentPatternString = nil
      currentPatternAction = nil
      estimatedTimeRemaining = nil
      updateStartedAt = nil
      return
    } catch {
      Logger.error("Update failed", category: .blockerViewModel, error: error)
      currentPatternString = nil
      currentPatternAction = nil
      estimatedTimeRemaining = nil
      updateStartedAt = nil
      updateState = .ok
      showUpdateError = true
      return
    }

    // Success - refresh data and set ok state
    currentPatternString = nil
    currentPatternAction = nil
    estimatedTimeRemaining = nil
    updateStartedAt = nil
    completedPatternsCount = await patternService.getCompletedPatternsCount()
    pendingPatternsCount = await patternService.getPendingPatternsCount()
    lastSuccessfulUpdateAt = userDefaults.getLastSuccessfulUpdateAt()
    lastListDownloadAt = userDefaults.getLastListDownloadAt()
    shouldUpdateList = userDefaults.shouldUpdateList()
    updateState = .ok
  }

  /// Updates the progress and the estimated time remaining from number-level progress
  /// Progress is weighted by phone numbers (not patterns), since processing time is
  /// proportional to the number of numbers sent to the Call Directory extension
  private func handleNumbersProgress(processedNumbers: Int64, totalNumbers: Int64) {
    guard totalNumbers > 0 else { return }

    let progress = min(Double(processedNumbers) * 100.0 / Double(totalNumbers), 100.0)
    updateState = .inProgress(progress: max(progress, 0.0))

    guard let startedAt = updateStartedAt, processedNumbers > 0 else {
      estimatedTimeRemaining = nil
      return
    }

    // Wait a few seconds before showing an estimate, to let the average rate settle
    let elapsed = Date().timeIntervalSince(startedAt)
    guard elapsed >= 5 else { return }

    let numbersPerSecond = Double(processedNumbers) / elapsed
    let remainingSeconds = Double(max(totalNumbers - processedNumbers, 0)) / numbersPerSecond

    if let previousEstimate = estimatedTimeRemaining {
      // Smooth the estimate to avoid jumps between chunks
      estimatedTimeRemaining = previousEstimate * 0.6 + remainingSeconds * 0.4
    } else {
      estimatedTimeRemaining = remainingSeconds
    }
  }

  /// Reinstalls the block list by resetting the extension and marking all patterns as pending
  func reinstallBlockList() async {
    await blockerService.resetExtensionState()

    // Refresh data to update counters
    await loadData()
  }

  func resetApplication() async {
    await blockerService.resetApplication(notificationService: notificationService)
  }
}
