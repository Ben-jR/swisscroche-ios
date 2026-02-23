import SwiftUI

struct InfoSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel
  @ObservedObject var blockerStatus: BlockerStatusViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "info.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "info.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Informations")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          updateInfoView
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

  @ViewBuilder
  private var updateInfoView: some View {
    VStack(spacing: 16) {
      statisticsListItem(
        icon: "phone.circle.fill",
        value: "\(blockerUpdate.totalPhoneNumbersCount.formatted())",
        label: "Numéros dans la base de données",
        color: .green
      )

      statisticsListItem(
        icon: "number.circle.fill",
        value: "\(blockerUpdate.totalPatternsCount)",
        label: "Préfixes dans la base de données",
        color: .green
      )

      statisticsListItem(
        icon: backgroundServiceIcon,
        value: backgroundServiceText,
        label: "Service en arrière-plan",
        color: backgroundServiceColor
      )

      if let lastListDownloadAt = blockerUpdate.lastListDownloadAt {
        statisticsListItem(
          icon: "arrow.down.circle.fill",
          value: formatDate(lastListDownloadAt),
          label: "Dernier téléchargement",
          color: .green
        )
      }

      if let lastSuccessfulUpdateAt = blockerUpdate.lastSuccessfulUpdateAt {
        statisticsListItem(
          icon: "checkmark.circle.fill",
          value: formatDate(lastSuccessfulUpdateAt),
          label: "Dernière mise à jour réussie",
          color: .green
        )
      }

      if let lastBackgroundLaunchAt = blockerUpdate.lastBackgroundLaunchAt {
        statisticsListItem(
          icon: "clock.circle.fill",
          value: formatDate(lastBackgroundLaunchAt),
          label: "Dernier lancement en arrière-plan",
          color: .green
        )
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  // MARK: - Helpers

  @ViewBuilder
  private func statisticsListItem(
    icon: String,
    value: String,
    label: String,
    color: Color
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(color)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .appFont(.subheadlineMedium)
          .foregroundColor(.primary)

        Text(value)
          .appFont(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }

  private var backgroundServiceIcon: String {
    blockerStatus.isBackgroundRefreshEnabled
      ? "arrow.clockwise.circle.fill" : "xmark.circle.fill"
  }

  private var backgroundServiceColor: Color {
    blockerStatus.isBackgroundRefreshEnabled ? .green : .red
  }

  private var backgroundServiceText: String {
    blockerStatus.isBackgroundRefreshEnabled
      ? "Service en arrière-plan actif"
      : "Désactivé - activez dans Réglages > Général > Actualisation en arrière-plan"
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter.string(from: date)
  }
}

#Preview {
  InfoSheet(
    blockerUpdate: BlockerUpdateViewModel(),
    blockerStatus: BlockerStatusViewModel()
  )
}
