import SwiftUI

@available(iOS 16.0, *)
struct ShortcutSetupSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var userPreferences: UserPreferencesViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            }

            Text("Raccourci automatique")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Créez une automatisation dans l'app Raccourcis pour mettre à jour la liste de blocage tous les jours, même sans ouvrir Saracroche."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "square.grid.2x2.fill",
                title: "Ouvrir l'app Raccourcis",
                description: "Lancez l'app Raccourcis d'Apple sur votre iPhone.",
                iconColor: .green
              )

              IconInfoRow(
                icon: "clock.fill",
                title: "Créer une automatisation quotidienne",
                description:
                  "Onglet Automatisation > Nouvelle automatisation > Heure de la journée et choisissez une heure.",
                iconColor: .green
              )

              IconInfoRow(
                icon: "arrow.clockwise",
                title: "Ajouter l'action Saracroche",
                description:
                  "Recherchez Saracroche > \"Mettre à jour\" et ajoutez cette action.",
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
            if let url = URL(string: "shortcuts://") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Ouvrir Raccourcis", systemImage: "square.grid.2x2.fill")
          }
          .buttonStyle(
            .fullWidth(background: .gray, foreground: .white)
          )

          Button {
            userPreferences.dismissShortcutSetup()
            dismiss()
          } label: {
            Label("J'ai configuré le raccourci", systemImage: "checkmark.circle.fill")
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

@available(iOS 16.0, *)
#Preview {
  ShortcutSetupSheet(
    userPreferences: UserPreferencesViewModel()
  )
}
