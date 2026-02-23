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
                .foregroundColor(.blue)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Filtre SMS")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Activez le filtre SMS pour que Saracroche filtre automatiquement les messages indésirables."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "message.fill",
                title: "Comment activer",
                description:
                  "Réglages > Apps > Messages > Filtrer les messages texte > Saracroche",
                iconColor: .blue
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
            userPreferences.dismissSmsFilterSetup()
            dismiss()
          } label: {
            Label("J'ai activé le filtre SMS", systemImage: "checkmark.circle.fill")
          }
          .buttonStyle(
            .fullWidth(background: .blue, foreground: .white)
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
