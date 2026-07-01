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
        .accessibilityLabel("Mettre à jour la liste malgré le mode économie d'énergie")
        Button("Annuler", role: .cancel) {}
          .accessibilityLabel("Annuler la mise à jour")
      } message: {
        Text(
          "La mise à jour des listes consomme de la batterie et peut vider votre batterie rapidement. Avec l’économisateur de batterie actif, la mise à jour sera ralentie."
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
