// Software Name: Saracroche iOS
// SPDX-FileCopyrightText: Copyright (c) Camille Bouvat
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0.en.html#license-text
// or see the "LICENSE" file for more details.

import SwiftUI

/// Adds low power mode awareness to a view that can trigger a heavy update.
/// Use `.lowPowerModeGuard(showUpdateSheet:)` on the view containing the trigger button.
struct LowPowerModeModifier: ViewModifier {
  @Binding var showUpdateInProgressSheet: Bool
  @Binding var showLowPowerAlert: Bool
  @Binding var isLowPowerMode: Bool

  func body(content: Content) -> some View {
    content
      .onReceive(
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
      ) { _ in
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
      }
      .alert("Mode économie d'énergie activé", isPresented: $showLowPowerAlert) {
        Button("Mettre à jour quand même") {
          showUpdateInProgressSheet = true
        }
        Button("Annuler", role: .cancel) {}
      } message: {
        Text(
          "La mise à jour de liste consomme de la batterie et peut vider votre batterie rapidement. Avec l’économisateur de batterie actif, la mise à jour sera ralentie."
        )
      }
  }
}

extension View {
  /// Guards the update sheet against low power mode.
  /// - Parameters:
  ///   - showUpdateInProgressSheet: binding that opens the update sheet
  ///   - showLowPowerAlert: local @State to drive the alert
  ///   - isLowPowerMode: local @State reflecting current low power state
  func lowPowerModeGuard(
    showUpdateInProgressSheet: Binding<Bool>,
    showLowPowerAlert: Binding<Bool>,
    isLowPowerMode: Binding<Bool>
  ) -> some View {
    modifier(
      LowPowerModeModifier(
        showUpdateInProgressSheet: showUpdateInProgressSheet,
        showLowPowerAlert: showLowPowerAlert,
        isLowPowerMode: isLowPowerMode
      )
    )
  }
}
