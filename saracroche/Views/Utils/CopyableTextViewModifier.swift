// Software Name: Saracroche iOS
// SPDX-FileCopyrightText: Copyright (c) Camille Bouvat
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0.en.html#license-text
// or see the "LICENSE" file for more details.

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
