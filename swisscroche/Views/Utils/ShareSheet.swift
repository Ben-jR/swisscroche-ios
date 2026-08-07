import SwiftUI
import UIKit

/// Wraps `UIActivityViewController` so a file can be shared on iOS 15.
///
/// SwiftUI's `ShareLink` would be simpler but is iOS 16+, and the deployment target
/// is iOS 15.6.
struct ShareSheet: UIViewControllerRepresentable {
  let items: [Any]
  var onDismiss: (() -> Void)?

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: items,
      applicationActivities: nil
    )
    controller.completionWithItemsHandler = { _, _, _, _ in
      onDismiss?()
    }
    return controller
  }

  func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
