import SwiftUI

struct ReinstallSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  // MARK: - State
  @State private var isReinstalling = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.rotate.byLayer, options: .repeat(.periodic(delay: 2)))
                .accessibilityHidden(true)
            } else {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
            }

            Text("Réinitialiser la liste de blocage.")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Les numéros installés seront supprimés de l'extension."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 16) {
              IconInfoRow(
                icon: "phone.fill.badge.checkmark",
                title: "Extension réinitialisée",
                description:
                  "Les numéros bloqués seront supprimés.",
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
            Task {
              isReinstalling = true
              await blockerUpdate.reinstallBlockList()
              dismiss()
            }
          } label: {
            HStack {
              if isReinstalling {
                ProgressView()
                  .tint(.white)
              } else {
                Image(systemName: "arrow.clockwise")
              }
              Text("Réinitialiser")
            }
          }
          .buttonStyle(
            .fullWidth(background: .blue, foreground: .white)
          )
          .disabled(isReinstalling)
        }
        .padding()
      }
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
          .disabled(isReinstalling)
        }
      }
    }
    .interactiveDismissDisabled(isReinstalling)
  }

}

#Preview {
  ReinstallSheet(blockerUpdate: BlockerUpdateViewModel())
}
