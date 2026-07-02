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
              "Activez ou désactivez le signalement dans les réglages pour pouvoir signaler les appels indésirables directement depuis le journal d'appel. Pour signaler un appel, glissez vers la droite sur un appel dans le journal d'appel et cliquez sur l'icône « main »."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "phone.fill",
                title: "Étape 1",
                description: "Ouvrir Réglages > Apps > Téléphone.",
                accessibleDescription: "Ouvrir Réglages, puis Apps, puis Téléphone.",
                iconColor: .green
              )

              IconInfoRow(
                icon: "bell.badge.fill",
                title: "Étape 2",
                description: "Sélectionner « Signalements des SMS/appels » > Saracroche.",
                accessibleDescription:
                  "Sélectionner « Signalements des SMS/appels », puis Saracroche.",
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
