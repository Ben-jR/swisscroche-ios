import BackgroundTasks
import Foundation
import UIKit

/// Background service for periodic updates
final class BackgroundService {

  // MARK: - Singleton
  static let shared = BackgroundService()

  // MARK: - Constants
  private let backgroundServiceIdentifier = AppConstants.backgroundServiceIdentifier
  private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval

  // MARK: - Properties
  private let userDefaults: UserDefaultsService

  // MARK: - Initialization
  private init() {
    self.userDefaults = UserDefaultsService()
  }

  /// Schedule background task
  private func scheduleBackgroundTask() {
    let taskRequest = BGProcessingTaskRequest(identifier: backgroundServiceIdentifier)
    let scheduledDate = Date(timeIntervalSinceNow: backgroundUpdateInterval)
    taskRequest.earliestBeginDate = scheduledDate
    taskRequest.requiresNetworkConnectivity = true
    taskRequest.requiresExternalPower = true

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      Logger.info(
        "Background app refresh task scheduled for \(scheduledDate)", category: .backgroundService)
    } catch {
      Logger.error(
        "Failed to schedule background app refresh", category: .backgroundService, error: error)
    }
  }

  /// Handle background update
  func handleBackgroundUpdate(task: BGProcessingTask) {
    Logger.info("Handling background app refresh", category: .backgroundService)

    scheduleBackgroundTask()
    userDefaults.setLastBackgroundLaunchAt(Date())

    let backgroundWork = Task {
      do {
        try await BlockerService().performBackgroundUpdate()
        if !Task.isCancelled {
          task.setTaskCompleted(success: true)
        }
      } catch is CancellationError {
        Logger.info(
          "Background update cancelled by expiration handler",
          category: .backgroundService)
      } catch {
        Logger.error("Background update failed", category: .backgroundService, error: error)
        if !Task.isCancelled {
          task.setTaskCompleted(success: false)
        }
      }
    }

    task.expirationHandler = {
      Logger.info("Background app refresh task expired", category: .backgroundService)
      backgroundWork.cancel()
      task.setTaskCompleted(success: false)
    }
  }
}

// MARK: - App Lifecycle Methods
extension BackgroundService {
  func applicationDidEnterBackground() {
    scheduleBackgroundTask()
  }

  func applicationWillTerminate() {
    scheduleBackgroundTask()
  }
}
