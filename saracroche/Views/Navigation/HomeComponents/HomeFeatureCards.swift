import SwiftUI

struct HomeFeatureCards: View {
  @ObservedObject var userPreferences: UserPreferencesViewModel
  @Binding var showSmsFilterSetupSheet: Bool
  @Binding var showCallReportingSetupSheet: Bool
  @Binding var showShortcutSetupSheet: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Protection")
        .appFont(.headlineSemiBold)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 4)

      Text("Activez toutes les protections pour profiter pleinement de Saracroche.")
        .appFont(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)

      notificationRow

      Divider().padding(.horizontal, 16)

      if #available(iOS 16.0, *) {
        featureRow(
          icon: "message.fill",
          title: "Filtre SMS",
          subtitle: "Filtrez les SMS indésirables",
          isConfigured: userPreferences.isSmsFilterSetupDismissed
        ) {
          showSmsFilterSetupSheet = true
        }

        Divider().padding(.horizontal, 16)
      }

      featureRow(
        icon: "phone.fill",
        title: "Signalement d'appels",
        subtitle: "Signalez les appels indésirables",
        isConfigured: userPreferences.isCallReportingSetupDismissed
      ) {
        showCallReportingSetupSheet = true
      }

      if #available(iOS 16.0, *) {
        Divider().padding(.horizontal, 16)

        featureRow(
          icon: "arrow.clockwise.circle.fill",
          title: "Raccourci automatique",
          subtitle: "Mise à jour automatique quotidienne",
          isConfigured: userPreferences.isShortcutSetupDismissed
        ) {
          showShortcutSetupSheet = true
        }
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  private func featureRow(
    icon: String,
    title: String,
    subtitle: String,
    isConfigured: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: isConfigured ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 22))
          .foregroundColor(isConfigured ? .green : .gray)
          .frame(width: 28)

        Image(systemName: icon)
          .font(.system(size: 16))
          .foregroundColor(.secondary)
          .frame(width: 20)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)
          Text(subtitle)
            .appFont(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private var notificationRow: some View {
    HStack(spacing: 12) {
      Image(
        systemName: userPreferences.isNotificationReminderEnabled
          ? "checkmark.circle.fill" : "circle"
      )
      .font(.system(size: 22))
      .foregroundColor(
        userPreferences.isNotificationReminderEnabled ? .green : .gray
      )
      .frame(width: 28)

      Image(systemName: "bell.badge.fill")
        .font(.system(size: 16))
        .foregroundColor(.secondary)
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 2) {
        Text("Rappel de mise à jour")
          .appFont(.subheadlineMedium)
          .foregroundColor(.primary)
        Text("Notification tous les 15 jours")
          .appFont(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      Toggle(
        "",
        isOn: Binding(
          get: { userPreferences.isNotificationReminderEnabled },
          set: { newValue in
            Task {
              if newValue {
                await userPreferences.enableNotificationReminder()
              } else {
                userPreferences.disableNotificationReminder()
              }
            }
          }
        )
      )
      .labelsHidden()
      .tint(Color("AppColor"))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}
