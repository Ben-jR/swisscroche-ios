import CallKit
import Foundation
import OSLog

/// Errors specific to the Call Directory extension
enum CallDirectoryHandlerError: Error {
  case sharedUserDefaultsUnavailable
}

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  private let logger = Logger(subsystem: "com.saracroche.blocker", category: "CallDirectoryHandler")

  /// Get shared UserDefaults
  private func sharedUserDefaults() -> UserDefaults? {
    UserDefaults(suiteName: AppConstants.appGroupIdentifier)
  }

  /// Handle CallKit request
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    logger.info("Starting request processing")

    context.delegate = self

    do {
      if context.isIncremental {
        try incrementalUpdate(to: context)
      } else {
        try fullUpdate(to: context)
      }
      context.completeRequest()
    } catch {
      logger.error("Request failed: \(error.localizedDescription)")
      context.cancelRequest(withError: error)
    }
  }

  /// Process incremental update
  private func incrementalUpdate(
    to context: CXCallDirectoryExtensionContext
  ) throws {
    guard let sharedDefaults = sharedUserDefaults() else {
      logger.error("Could not access shared UserDefaults")
      throw CallDirectoryHandlerError.sharedUserDefaultsUnavailable
    }

    let action = sharedDefaults.string(forKey: AppConstants.SharedDefaultsKeys.action) ?? ""
    let numbersData =
      sharedDefaults.array(forKey: AppConstants.SharedDefaultsKeys.numbers) as? [[String: Any]]
      ?? []

    // Clear shared defaults after reading
    sharedDefaults.set("", forKey: AppConstants.SharedDefaultsKeys.action)
    sharedDefaults.set([], forKey: AppConstants.SharedDefaultsKeys.numbers)

    // Process action using switch statement
    switch action {
    case "reset":
      // Handle reset action
      handleResetAction(to: context)
      addFakeNumbers(to: context)

    case "":
      // Handle empty action
      handleNoAction()

    case "block", "identify", "remove_block", "remove_identify":
      // Validate we have numbers to process
      guard !numbersData.isEmpty else {
        logger.debug("No numbers to process for action: \(action)")
        return
      }

      // Process the specific action
      logger.info("Processing action \(action) with \(numbersData.count) numbers")

      switch action {
      case "block":
        processBlockingEntries(numbersData, context: context)
      case "identify":
        processIdentificationEntries(numbersData, context: context)
      case "remove_block":
        processRemoveBlockingEntries(numbersData, context: context)
      case "remove_identify":
        processRemoveIdentificationEntries(numbersData, context: context)
      default:
        break  // This case is already handled by the outer switch
      }

    default:
      // Handle unknown action
      if !action.isEmpty {
        logger.warning("Unknown action: \(action)")
      }
    }
  }

  // MARK: - Action Handlers

  /// Handle reset action - clear all entries
  private func handleResetAction(to context: CXCallDirectoryExtensionContext) {
    logger.info("Processing reset action")
    context.removeAllBlockingEntries()
    context.removeAllIdentificationEntries()
    logger.info("Reset all blocking and identification entries")
  }

  /// Handle case where no action is specified
  private func handleNoAction() {
    logger.debug("No action specified")
  }

  // MARK: - Number Processing Methods

  /// Process blocking entries - add numbers to block list
  private func processBlockingEntries(
    _ numbersData: [[String: Any]],
    context: CXCallDirectoryExtensionContext
  ) {
    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }
      context.addBlockingEntry(withNextSequentialPhoneNumber: number)
    }
  }

  /// Process identification entries - add numbers to identification list
  private func processIdentificationEntries(
    _ numbersData: [[String: Any]],
    context: CXCallDirectoryExtensionContext
  ) {
    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }
      let name = numberData["name"] as? String ?? ""
      context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: name)
    }
  }

  /// Process removal of blocking entries
  private func processRemoveBlockingEntries(
    _ numbersData: [[String: Any]],
    context: CXCallDirectoryExtensionContext
  ) {
    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }
      context.removeBlockingEntry(withPhoneNumber: number)
    }
  }

  /// Process removal of identification entries
  private func processRemoveIdentificationEntries(
    _ numbersData: [[String: Any]],
    context: CXCallDirectoryExtensionContext
  ) {
    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }
      context.removeIdentificationEntry(withPhoneNumber: number)
    }
  }

  // MARK: - Utility Methods

  /// Add fake numbers to ensure iOS recognizes the extension is working
  private func addFakeNumbers(to context: CXCallDirectoryExtensionContext) {
    context.addBlockingEntry(withNextSequentialPhoneNumber: 1_800_555_5555)
    context.addIdentificationEntry(withNextSequentialPhoneNumber: 1_888_555_5555, label: "Fake")
  }

  /// Process full update (non-incremental)
  private func fullUpdate(to context: CXCallDirectoryExtensionContext) throws {
    // Clear any stale data from previous operations
    if let sharedDefaults = sharedUserDefaults() {
      sharedDefaults.set("", forKey: AppConstants.SharedDefaultsKeys.action)
      sharedDefaults.set([], forKey: AppConstants.SharedDefaultsKeys.numbers)
    }
    addFakeNumbers(to: context)
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
  /// Handle request failure
  func requestFailed(
    for extensionContext: CXCallDirectoryExtensionContext,
    withError error: Error
  ) {
    logger.error(
      "Request failed with error: \(error.localizedDescription)")
  }
}
