import SwiftUI

@available(iOS 16.0, *)
struct SmsFilterSetupSheet: View {
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
              Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
                .accessibilityHidden(true)
            } else {
              Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .accessibilityHidden(true)
            }

            Text("Filtre SMS")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Activez ou désactivez le filtre SMS dans les réglages pour que Saracroche filtre automatiquement les messages indésirables."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "gear",
                title: "Étape 1",
                description: "Ouvrir Réglages > Apps > Messages.",
                accessibleDescription: "Ouvrir Réglages, puis Apps, et ensuite Messages.",
                iconColor: .green
              )

              IconInfoRow(
                icon: "person.crop.circle.badge.exclamationmark",
                title: "Étape 2",
                description: "Activer \"Filtrer les expéditeurs inconnus\".",
                iconColor: .green
              )

              IconInfoRow(
                icon: "message.fill",
                title: "Étape 3",
                description: "Sélectionner \"Filtrer les messages texte\" > Saracroche.",
                accessibleDescription:
                  "Sélectionner \"Filtrer les messages texte\", puis Saracroche.",
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

@available(iOS 16.0, *)
#Preview {
  SmsFilterSetupSheet(
    blockerStatus: BlockerStatusViewModel(),
    userPreferences: UserPreferencesViewModel()
  )
}
