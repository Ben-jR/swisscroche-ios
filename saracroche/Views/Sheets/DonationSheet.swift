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

            Text("Soutenez Saracroche")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Saracroche est développée par Camille sur son temps libre. Vos dons permettent d'améliorer l'application et de maintenir les listes de blocage à jour. "
                + "Une note sur le store est toujours appréciée et aide beaucoup !"
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
                icon: "person.fill",
                title: "Développement indépendant",
                description: "Création par Camille."
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
            Button {
              if let url = URL(string: "https://donate.stripe.com/9B6aEXcJ8flofsgfIU2oE01") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "creditcard.fill")
                Text("Carte Bancaire et Apple Pay")
              }
            }
            .buttonStyle(
              .fullWidth(background: .indigo, foreground: .white)
            )
            .accessibilityAddTraits(.isLink)
            .accessibilityRemoveTraits(.isButton)

            Button {
              if let url = URL(
                string:
                  "https://www.paypal.com/donate/?hosted_button_id=PPMLFH859R58N&locale.x=fr_FR")
              {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "wallet.bifold.fill")
                Text("PayPal")
              }
            }
            .buttonStyle(
              .fullWidth(background: .blue, foreground: .white)
            )
            .accessibilityAddTraits(.isLink)
            .accessibilityRemoveTraits(.isButton)

            Button {
              if let url = URL(string: "https://liberapay.com/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "eurosign.circle.fill")
                Text("Liberapay")
              }
            }
            .buttonStyle(
              .fullWidth(background: .yellow, foreground: .black)
            )
            .accessibilityAddTraits(.isLink)
            .accessibilityRemoveTraits(.isButton)

            Button {
              if let url = URL(
                string:
                  "https://apps.apple.com/app/id6743679292?action=write-review"
              ) {
                UIApplication.shared.open(url)
              }
            } label: {
              Label("Noter l'application", systemImage: "star.bubble.fill")
            }
            .buttonStyle(
              .fullWidth(background: .pink, foreground: .white)
            )
            .accessibilityAddTraits(.isLink)
            .accessibilityRemoveTraits(.isButton)

            Button {
              userPreferences.dismissDonation()
              dismiss()
            } label: {
              Label("Plus tard, non merci", systemImage: "xmark")
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
