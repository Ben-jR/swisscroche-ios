import SwiftUI

struct DonationSheet: View {
  @ObservedObject var userPreferences: UserPreferencesViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
                .symbolEffect(.bounce.down.byLayer, options: .repeat(.periodic(delay: 2.0)))
                .accessibilityHidden(true)
            } else {
              Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
                .accessibilityHidden(true)
            }

            Text("Soutenez SwissCroche")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "SwissCroche est un fork indépendant de Saracroche, adapté pour la Suisse. "
                + "C'est un projet open source et gratuit, sans lien avec l'équipe originale."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "curlybraces.square.fill",
                title: "Projet open source",
                description: "Code source ouvert et transparent."
              )

              IconInfoRow(
                icon: "gift.fill",
                title: "Entièrement gratuit",
                description:
                  "Pas de pub, pas d'abonnement, pas de version premium.",
                accessibleDescription:
                  "Pas de publicité, pas d'abonnement, pas de version premium."
              )

              IconInfoRow(
                icon: "arrow.clockwise.circle.fill",
                title: "Mises à jour régulières",
                description:
                  "Nouvelles listes de blocage et améliorations continues."
              )

              IconInfoRow(
                icon: "lock.shield.fill",
                title: "Confidentialité respectée",
                description:
                  "Aucune donnée collectée, tout reste sur votre appareil."
              )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            )
          }

          VStack(spacing: 16) {
            // TODO: add SwissCroche's own donation links and App Store review link once published.
            Button {
              userPreferences.dismissDonation()
              dismiss()
            } label: {
              Label("Compris", systemImage: "checkmark")
            }
            .buttonStyle(
              .fullWidth(background: .black, foreground: .white)
            )
          }
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
  DonationSheet(userPreferences: UserPreferencesViewModel())
}
