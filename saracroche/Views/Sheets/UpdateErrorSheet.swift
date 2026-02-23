import SwiftUI

struct UpdateErrorSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            }

            Text("La mise à jour a échoué")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "La mise à jour n'a pas pu être finalisée. Cela peut arriver lorsque le système d'exploitation est temporairement indisponible."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "clock.fill",
                title: "Patientez 48 heures",
                description:
                  "Laissez le système se stabiliser avant de réessayer",
                iconColor: .orange
              )

              IconInfoRow(
                icon: "power.circle.fill",
                title: "Redémarrez votre appareil",
                description:
                  "Un redémarrage permet de réinitialiser les services système",
                iconColor: .orange
              )

              IconInfoRow(
                icon: "arrow.clockwise.circle.fill",
                title: "Relancez la mise à jour",
                description:
                  "Réessayez la mise à jour depuis l'écran d'accueil",
                iconColor: .orange
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
            dismiss()
          } label: {
            Text("J'ai compris")
          }
          .buttonStyle(
            .fullWidth(background: .orange, foreground: .white)
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
  UpdateErrorSheet()
}
