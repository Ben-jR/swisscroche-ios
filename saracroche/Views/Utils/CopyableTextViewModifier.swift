import SwiftUI
import UIKit

/// `ViewModifier` to allow the user to copy in its clipboard the given value
/// to then paste it elsewhere. Can be sueful for Fediverse accounts handles.
struct CopyableTextViewModifier: ViewModifier {

  let copyable: String

  func body(content: Content) -> some View {
    content
      .contextMenu {
        Button(
          action: {
            let pasteboard = UIPasteboard.general
            pasteboard.string = copyable
          },
          label: {
            Text("Copier dans le presse-papiers")
            Image(systemName: "doc.on.doc").accessibilityHidden(true)
          })
      }
  }
}
