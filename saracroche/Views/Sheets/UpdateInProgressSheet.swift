import SwiftUI

struct UpdateInProgressSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  // MARK: - State
  @State private var isFirstInstall: Bool = true

  /// Returns a human-readable label for the current pattern action
  private var currentPatternActionLabel: String {
    switch blockerUpdate.currentPatternAction {
    case "identify": return "Ajout de l'identification de"
    case "remove_block": return "Retrait du blocage de"
    case "remove_identify": return "Retrait de l'identification de"
    default: return "Ajout du blocage de"
    }
  }

  var body: some View {
    NavigationView {
      VStack {
        Spacer()

        VStack(spacing: 16) {
          if #available(iOS 18.0, *) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.blue)
              .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
          } else {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.blue)
          }

          Text(isFirstInstall ? "Installation en cours" : "Mise à jour en cours")
            .appFont(.titleBold)
            .multilineTextAlignment(.center)

          VStack(spacing: 16) {
            if case .inProgress(let progress) = blockerUpdate.updateState {
              Text(String(format: "%.2f%%", progress))
                .appFont(.headlineSemiBold)
                .foregroundColor(.blue)

              ProgressView(
                value: progress,
                total: 100.0
              )
              .tint(.blue)

              if let patternString = blockerUpdate.currentPatternString {
                Text("\(currentPatternActionLabel) \(patternString)")
                  .appFont(.caption)
                  .foregroundColor(.secondary)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            } else {
              ProgressView(
                value: 0,
                total: 100.0
              )
              .tint(.blue)
            }

            Text("Gardez l'application ouverte pendant l'installation.")
              .appFont(.bodyBold)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.gray.opacity(0.1))
          )
        }

        Spacer()

        HStack(alignment: .center, spacing: 12) {
          Image(systemName: "info.circle.fill")
            .font(.system(size: 16))
            .foregroundColor(.blue)
            .frame(width: 24, height: 24)

          Text(
            "Les numéros sont ajoutés un par un pour être bloqués ou identifiés par le système d'exploitation."
          )
          .appFont(.caption)
          .foregroundColor(.secondary)

          Spacer()
        }

        HStack(alignment: .center, spacing: 12) {
          Image(systemName: "battery.100.bolt")
            .font(.system(size: 16))
            .foregroundColor(.blue)
            .frame(width: 24, height: 24)

          Text("Il est préférable de faire cette mise à jour en branchant l'appareil.")
            .appFont(.caption)
            .foregroundColor(.secondary)

          Spacer()
        }

        HStack(alignment: .center, spacing: 12) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 16))
            .foregroundColor(.blue)
            .frame(width: 24, height: 24)

          Text("Les mises à jour se font aussi en arrière-plan quand l'appareil est en charge.")
            .appFont(.caption)
            .foregroundColor(.secondary)

          Spacer()
        }
      }
      .padding()
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            blockerUpdate.isCancellationRequested = true
            dismiss()
          }
        }
      }
    }
    .task {
      isFirstInstall = blockerUpdate.completedPatternsCount == 0
      UIApplication.shared.isIdleTimerDisabled = true
      await blockerUpdate.performUpdateWithStateManagement()
      UIApplication.shared.isIdleTimerDisabled = false
      dismiss()
    }
    .onDisappear {
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
}

#Preview {
  UpdateInProgressSheet(blockerUpdate: BlockerUpdateViewModel())
}
