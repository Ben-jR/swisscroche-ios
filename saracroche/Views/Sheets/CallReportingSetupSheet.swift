import SwiftUI

struct CallReportingSetupSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerStatus: BlockerStatusViewModel
  @ObservedObject var userPreferences: UserPreferencesViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "phone.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "phone.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            }

            Text("Signalement d'appels")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Activez le signalement pour pouvoir signaler les appels indésirables directement depuis l'historique d'appels."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "phone.fill",
                title: "Comment activer",
                description:
                  "Réglages > Apps > Téléphone > Signalements des SMS/appels > Saracroche",
                iconColor: .green
              )
            }
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.gray.opacity(0.1))
          )

          Button {
            blockerStatus.openPhoneSettings()
          } label: {
            Label("Ouvrir les réglages", systemImage: "gear")
          }
          .buttonStyle(
            .fullWidth(background: .gray, foreground: .white)
          )

          Button {
            userPreferences.dismissCallReportingSetup()
            dismiss()
          } label: {
            Label("J'ai activé le signalement", systemImage: "checkmark.circle.fill")
          }
          .buttonStyle(
            .fullWidth(background: .green, foreground: .white)
          )
        }
        .padding()
      }
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  CallReportingSetupSheet(
    blockerStatus: BlockerStatusViewModel(),
    userPreferences: UserPreferencesViewModel()
  )
}
