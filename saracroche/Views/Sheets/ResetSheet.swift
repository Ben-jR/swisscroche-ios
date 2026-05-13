import SwiftUI

struct ResetSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  // MARK: - State
  @State private var isResetting = false
  @State private var showResetComplete = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            }

            Text("Réinitialiser l'application")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Cette action est irréversible. Toutes les données seront supprimées."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "phone.fill.badge.checkmark",
                title: "Numéros bloqués supprimés",
                description: "Tous les numéros et préfixes installés seront effacés.",
                iconColor: .red
              )

              IconInfoRow(
                icon: "gearshape.fill",
                title: "Réglages réinitialisés",
                description: "Vos préférences reviendront aux valeurs par défaut.",
                iconColor: .red
              )

              IconInfoRow(
                icon: "xmark.app.fill",
                title: "Fermeture de l'application",
                description:
                  "Vous devrez fermer l'application manuellement après la réinitialisation.",
                iconColor: .red
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
            Task {
              isResetting = true
              await blockerUpdate.resetApplication()
              isResetting = false
              showResetComplete = true
            }
          } label: {
            HStack {
              if isResetting {
                ProgressView()
                  .tint(.white)
              } else {
                Image(systemName: "trash.fill")
              }
              Text("Réinitialiser")
            }
          }
          .buttonStyle(
            .fullWidth(background: .red, foreground: .white)
          )
          .disabled(isResetting)
        }
        .padding()
      }
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
          .disabled(isResetting)
        }
      }
      .sheet(isPresented: $showResetComplete) {
        ResetCompleteSheet()
      }
    }
    .interactiveDismissDisabled(isResetting)
  }

}

#Preview {
  ResetSheet(blockerUpdate: BlockerUpdateViewModel())
}
