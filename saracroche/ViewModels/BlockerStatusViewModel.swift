import SwiftUI

/// View model for extension status and system state
@MainActor
class BlockerStatusViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var isBackgroundRefreshEnabled: Bool = false

  // MARK: - Dependencies

  private let blockerService: BlockerService

  // MARK: - Initialization

  init(blockerService: BlockerService = BlockerService()) {
    self.blockerService = blockerService
  }

  // MARK: - Extension Status

  func checkBlockerExtensionStatus() async {
    do {
      blockerExtensionStatus = try await blockerService.checkExtensionStatus()
    } catch {
      Logger.error("Failed to check extension status", category: .blockerViewModel, error: error)
      blockerExtensionStatus = .error
    }
  }

  func checkBackgroundStatus() async {
    isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
  }

  func openSettings() async {
    do {
      try await blockerService.openSettings()
    } catch {
      Logger.error("Failed to open settings", category: .blockerViewModel, error: error)
    }
  }

  /// Opens the Phone settings in iOS Settings
  func openPhoneSettings() {
    if let url = URL(string: "App-Prefs:root=Phone&path=SILENCE_CALLS") {
      UIApplication.shared.open(url)
    }
  }
}
