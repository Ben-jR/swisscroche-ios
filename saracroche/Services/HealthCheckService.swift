import BackgroundTasks
import Foundation

/// Service for managing periodic health check requests
final class HealthCheckService {

  // MARK: - Singleton

  static let shared = HealthCheckService()

  // MARK: - Constants

  private let healthCheckInterval: TimeInterval = 12 * 60 * 60  // 12 hours

  // MARK: - Properties

  private let sharedUserDefaultsService: SharedUserDefaultsService
  private let healthCheckAPIService: HealthCheckAPIService
  private var timer: Timer?
  private var isRunning = false

  // MARK: - Initialization

  private init() {
    self.sharedUserDefaultsService = SharedUserDefaultsService()
    self.healthCheckAPIService = HealthCheckAPIService.shared
  }

  deinit {
    stop()
  }

  // MARK: - Service Lifecycle

  /// Start the health check service
  func start() {
    guard !isRunning else { return }

    isRunning = true
    Logger.info("HealthCheckService started", category: .healthCheck)

    // Schedule background task
    scheduleBackgroundTask()

    // Start foreground timer
    startForegroundTimer()

    // Perform immediate health check if API key is available
    if hasAPIKey() {
      performHealthCheck()
    }
  }

  /// Stop the health check service
  func stop() {
    guard isRunning else { return }

    Logger.info("HealthCheckService stopped", category: .healthCheck)

    timer?.invalidate()
    timer = nil
    isRunning = false
  }

  // MARK: - Background Task Scheduling

  private func scheduleBackgroundTask() {
    let taskRequest = BGProcessingTaskRequest(identifier: AppConstants.healthCheckServiceIdentifier)
    let scheduledDate = Date(timeIntervalSinceNow: healthCheckInterval)
    taskRequest.earliestBeginDate = scheduledDate
    taskRequest.requiresNetworkConnectivity = true

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      Logger.info(
        "Health check background task scheduled for \(scheduledDate)",
        category: .healthCheck
      )
    } catch {
      Logger.error(
        "Failed to schedule health check background task",
        category: .healthCheck,
        error: error
      )
    }
  }

  // MARK: - Foreground Timer

  private func startForegroundTimer() {
    // Invalidate existing timer
    timer?.invalidate()

    // Create new timer that fires every 12 hours
    timer = Timer.scheduledTimer(
      withTimeInterval: healthCheckInterval,
      repeats: true
    ) { [weak self] _ in
      self?.performHealthCheck()
    }

    Logger.info("Health check foreground timer started", category: .healthCheck)
  }

  // MARK: - Health Check Execution

  private func performHealthCheck() {
    guard hasAPIKey() else {
      Logger.info("Skipping health check: no API key", category: .healthCheck)
      return
    }

    // Check if we've already performed a health check recently
    if let lastCheck = sharedUserDefaultsService.getLastHealthCheckAt() {
      let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
      if timeSinceLastCheck < healthCheckInterval {
        Logger.info(
          "Skipping health check: last check was \(timeSinceLastCheck / 3600) hours ago",
          category: .healthCheck
        )
        return
      }
    }

    Task {
      do {
        try await healthCheckAPIService.sendHealthCheck()
        sharedUserDefaultsService.setLastHealthCheckAt(Date())
      } catch {
        // Only log errors, don't notify user
        Logger.error("Health check request failed", category: .healthCheck, error: error)
      }
    }
  }

  /// Check if an organization API key is available
  /// - Returns: true if API key is available, false otherwise
  private func hasAPIKey() -> Bool {
    return sharedUserDefaultsService.getOrganizationAPIKey() != nil
  }

  // MARK: - Public Methods

  /// Manually trigger a health check
  func triggerHealthCheck() {
    Logger.info("Manual health check triggered", category: .healthCheck)
    performHealthCheck()
  }

  /// Handle background health check task
  func handleBackgroundHealthCheck(task: BGProcessingTask) {
    Logger.info("Handling background health check", category: .healthCheck)

    // Schedule next task
    scheduleBackgroundTask()

    let healthCheckWork = Task {
      performHealthCheck()
      if !Task.isCancelled {
        task.setTaskCompleted(success: true)
      }
    }

    task.expirationHandler = {
      Logger.info("Health check background task expired", category: .healthCheck)
      healthCheckWork.cancel()
      task.setTaskCompleted(success: false)
    }
  }
}
