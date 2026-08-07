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
                .accessibilityHidden(true)
            } else {
              Image(systemName: "info.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
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
        label: "Numéros dans la base de données",
        value: "\(blockerUpdate.totalPhoneNumbersCount)",
        spelledOut: blockerUpdate.totalPhoneNumbersCount.spelledOut,
        color: .green
      )

      statisticsListItem(
        icon: "number.circle.fill",
        label: "Préfixes dans la base de données",
        value: "\(blockerUpdate.totalPatternsCount)",
        spelledOut: blockerUpdate.totalPatternsCount.spelledOut,
        color: .green
      )

      statisticsListItem(
        icon: backgroundServiceIcon,
        label: "Service en arrière-plan",
        value: backgroundServiceText,
        color: backgroundServiceColor
      )

      if let lastListDownloadAt = blockerUpdate.lastListDownloadAt {
        statisticsListItem(
          icon: "arrow.down.circle.fill",
          label: "Dernier téléchargement",
          value: formatDate(lastListDownloadAt),
          color: .green
        )
      }

      if let lastSuccessfulUpdateAt = blockerUpdate.lastSuccessfulUpdateAt {
        statisticsListItem(
          icon: "checkmark.circle.fill",
          label: "Dernière mise à jour réussie",
          value: formatDate(lastSuccessfulUpdateAt),
          color: .green
        )
      }

      if let lastBackgroundLaunchAt = blockerUpdate.lastBackgroundLaunchAt {
        statisticsListItem(
          icon: "clock.circle.fill",
          label: "Dernier lancement en arrière-plan",
          value: formatDate(lastBackgroundLaunchAt),
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
    label: String,
    value: String,
    spelledOut: String = "",
    color: Color
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(color)
        .frame(width: 24)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .appFont(.subheadlineMedium)
          .foregroundColor(.primary)

        Text(value)
          .appFont(.caption)
          .foregroundColor(.secondary)
          .accessibilityLabel(!spelledOut.isEmpty ? spelledOut : value)
      }

      Spacer()
    }.accessibilityElement(children: .combine)
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
    formatter.locale = Locale(identifier: "fr_CH")
    return formatter.string(from: date)
  }
}

#Preview {
  InfoSheet(
    blockerUpdate: BlockerUpdateViewModel(),
    blockerStatus: BlockerStatusViewModel()
  )
}
