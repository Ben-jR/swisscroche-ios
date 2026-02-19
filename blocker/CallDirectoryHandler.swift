import CallKit
import Foundation
import OSLog

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  private let logger = Logger(subsystem: "com.saracroche.blocker", category: "CallDirectoryHandler")

  /// Get shared UserDefaults
  private func sharedUserDefaults() -> UserDefaults? {
    UserDefaults(suiteName: "group.com.cbouvat.saracroche")
  }

  /// Handle CallKit request
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    logger.info("Starting request processing")

    context.delegate = self

    if context.isIncremental {
      incrementalUpdate(to: context)
    } else {
      fullUpdate(to: context)
    }

    context.completeRequest()
  }

  /// Process incremental update
  private func incrementalUpdate(
    to context: CXCallDirectoryExtensionContext
  ) {
    guard let sharedDefaults = sharedUserDefaults() else {
      logger.error(
        "Could not access shared UserDefaults")
      return
    }

    let action = sharedDefaults.string(forKey: "action") ?? ""
    let numbersData = sharedDefaults.array(forKey: "numbers") as? [[String: Any]] ?? []

    sharedDefaults.set("", forKey: "action")
    sharedDefaults.set([], forKey: "numbers")

    if action == "reset" {
      handleResetAction(to: context)
      return
    }

    if action.isEmpty {
      handleNoAction()
      return
    }

    processNumberEntries(numbersData, action: action, context: context)
  }

  /// Process full update (non-incremental)
  private func fullUpdate(to context: CXCallDirectoryExtensionContext) {
    // Add fake numbers to ensure iOS recognizes the extension is working
    context.addBlockingEntry(withNextSequentialPhoneNumber: 1_800_555_5555)
    context.addIdentificationEntry(withNextSequentialPhoneNumber: 1_888_555_5555, label: "Fake")
  }

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

  /// Process number entries for a specific action
  private func processNumberEntries(
    _ numbersData: [[String: Any]],
    action: String,
    context: CXCallDirectoryExtensionContext
  ) {
    logger.info("Processing action \(action) with \(numbersData.count) numbers")

    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }
      let name = numberData["name"] as? String ?? ""

      switch action {
      case "block":
        context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        logger.info(
          "Blocked number: \(number) - \(name)")
      case "identify":
        context.addIdentificationEntry(
          withNextSequentialPhoneNumber: number, label: name)
        logger.info(
          "Identified number: \(number) - \(name)")
      case "remove_block":
        context.removeBlockingEntry(withPhoneNumber: number)
        logger.info(
          "Removed blocking entry: \(number)")
      case "remove_identify":
        context.removeIdentificationEntry(withPhoneNumber: number)
        logger.info(
          "Removed identification entry: \(number)")
      default:
        logger.warning(
          "Unknown action: \(action)")
      }
    }
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
