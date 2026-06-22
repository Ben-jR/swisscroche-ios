import SwiftUI

struct BusinessCodeSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.bounce.down.byLayer, options: .repeat(.periodic(delay: 2.0)))
                .accessibilityHidden(true)
            } else {
              Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
            }

            Text("Saracroche pour les entreprises")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(
              "Découvrez les fonctionnalités dédiées aux entreprises et organisations pour répondre à vos besoins spécifiques de protection."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)
          }

          VStack(alignment: .leading, spacing: 16) {
            IconInfoRow(
              icon: "chart.bar.doc.horizontal.fill",
              title: "Dashboard de gestion",
              description:
                "Gérez les signalements et les données de blocage depuis une interface centralisée."
            )

            IconInfoRow(
              icon: "person.3.fill",
              title: "Listes personnalisées",
              description:
                "Créez et gérez vos listes autorisées pour toujours recevoir les appels des numéros de confiance."
            )

            IconInfoRow(
              icon: "exclamationmark.bubble.fill",
              title: "Signalement centralisé",
              description:
                "Remontée centralisée des appels indésirables pour toute l'entreprise."
            )

            IconInfoRow(
              icon: "phone.fill.badge.checkmark",
              title: "Blocage multi-canaux",
              description:
                "Blocage des appels et SMS indésirables, protection contre le phishing."
            )

            IconInfoRow(
              icon: "server.rack",
              title: "Déploiement MDM",
              description:
                "Configuration centralisée, déploiement sans action manuelle requise."
            )

            IconInfoRow(
              icon: "arrow.clockwise.circle.fill",
              title: "Mises à jour automatiques",
              description:
                "Protection toujours à jour grâce aux mises à jour en arrière-plan."
            )
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.gray.opacity(0.1))
          )

          Button {
            if let url = URL(string: "https://saracroche.org/fr/business") {
              UIApplication.shared.open(url)
            }
          } label: {
            HStack {
              Image(systemName: "safari.fill")
              Text("Découvrir l'offre entreprise")
            }
          }
          .buttonStyle(.fullWidth(background: .blue, foreground: .white))
          .accessibilityRemoveTraits(.isButton)
          .accessibilityAddTraits(.isLink)
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
  BusinessCodeSheet()
}
