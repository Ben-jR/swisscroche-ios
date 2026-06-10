import SwiftUI
import UIKit

/// `ViewModifier` to apply on a `View` so as to trigger vibrations
/// according to the given `BlockerExtensionStatus`.
/// Should help users to notice more easily the status of the blocker.
struct BlockerStatusHapticModifier: ViewModifier {

  let status: BlockerExtensionStatus
  @State private var generator: UINotificationFeedbackGenerator?

  func body(content: Content) -> some View {
    content
      .onAppear {
        generator = UINotificationFeedbackGenerator()
        triggerHaptic()
      }
      .onChange(of: status) { _ in
        triggerHaptic()
      }
  }

  private func triggerHaptic() {
    generator?.notificationOccurred(hapticType)
  }

  private var hapticType: UINotificationFeedbackGenerator.FeedbackType {
    switch status {
    case .disabled: return .warning
    case .error, .unknown, .unexpected: return .error
    case .enabled: return .success
    }
  }
}
