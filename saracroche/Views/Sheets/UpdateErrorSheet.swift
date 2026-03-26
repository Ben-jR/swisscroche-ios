import SwiftUI

struct UpdateErrorSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        if #available(iOS 18.0, *) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60))
            .symbolEffect(
              .wiggle.up.byLayer,
              options: .repeat(.periodic(delay: 2.5))
            )
            .foregroundColor(.orange)
        } else {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60))
            .foregroundColor(.orange)
        }

        Text("La mise à jour a échoué")
          .appFont(.titleBold)
          .multilineTextAlignment(.center)

        VStack(alignment: .leading, spacing: 16) {
          Text(
            "La liste de blocage n'a pas pu être téléchargée. Cela peut arriver lorsque la connexion internet est temporairement indisponible."
          )
          .appFont(.body)
          .foregroundColor(.secondary)

          HStack(spacing: 12) {
            Image(systemName: "wifi.circle.fill")
              .font(.system(size: 28))
              .foregroundColor(.orange)
              .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
              Text("Vérifiez votre connexion")
                .appFont(.subheadlineMedium)
                .foregroundColor(.primary)

              Text("Assurez-vous d'être connecté au Wi-Fi ou au réseau mobile.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }

          HStack(spacing: 12) {
            Image(systemName: "arrow.clockwise.circle.fill")
              .font(.system(size: 28))
              .foregroundColor(.orange)
              .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
              Text("Relancez la mise à jour")
                .appFont(.subheadlineMedium)
                .foregroundColor(.primary)

              Text("Réessayez depuis l'écran d'accueil.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }

          HStack(spacing: 12) {
            Image(systemName: "clock.circle.fill")
              .font(.system(size: 28))
              .foregroundColor(.orange)
              .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
              Text("Patientez quelques minutes")
                .appFont(.subheadlineMedium)
                .foregroundColor(.primary)

              Text("Le serveur peut être temporairement indisponible.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.1))
        )

        Button {
          dismiss()
        } label: {
          Text("Réessayer plus tard")
        }
        .buttonStyle(
          .fullWidth(background: Color.orange, foreground: .white)
        )
        Spacer()
      }
      .padding()
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
