import SwiftUI

struct HomeInstallCard: View {
  @Binding var showUpdateInProgressSheet: Bool
  @State private var isLowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
  @State private var showLowPowerAlert: Bool = false

  private func handleUpdateAction() {
    if isLowPowerMode {
      showLowPowerAlert = true
    } else {
      showUpdateInProgressSheet = true
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.down.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .pulse.byLayer,
            options: .repeat(.periodic(delay: 2.0))
          )
          .foregroundColor(.blue)
          .accessibilityHidden(true)
      } else {
        Image(systemName: "arrow.down.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
          .accessibilityHidden(true)
      }

      Text("La liste n'est pas installée")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      Text("Installez la liste pour commencer à bloquer les appels indésirables.")
        .appFont(.body)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        handleUpdateAction()
      } label: {
        HStack {
          Image(systemName: "arrow.down.circle.fill")
          Text("Installez la liste de blocage")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.15))
    )
    .lowPowerModeGuard(
      showUpdateInProgressSheet: $showUpdateInProgressSheet,
      showLowPowerAlert: $showLowPowerAlert,
      isLowPowerMode: $isLowPowerMode
    )
  }
}
