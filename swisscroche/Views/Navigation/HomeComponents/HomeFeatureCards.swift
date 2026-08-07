import SwiftUI

struct HomeFeatureCards: View {
  @ObservedObject var userPreferences: UserPreferencesViewModel
  @Binding var showShortcutSetupSheet: Bool
  @Binding var showSmsFilterSetupSheet: Bool
  @Binding var showCallReportingSetupSheet: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Protection")
        .appFont(.headlineSemiBold)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 4)

      Text("Activez toutes les protections pour profiter pleinement de SwissCroche.")
        .appFont(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)

      notificationRow

      if #available(iOS 16.0, *) {
        Divider().padding(.horizontal, 16)

        featureRow(
          icon: "arrow.clockwise.circle.fill",
          title: "Raccourci automatique",
          subtitle: "Mise à jour automatique quotidienne sans intervention."
        ) {
          showShortcutSetupSheet = true
        }
      }

      if #available(iOS 16.0, *) {
        Divider().padding(.horizontal, 16)

        featureRow(
          icon: "message.fill",
          title: "Filtre SMS",
          subtitle: "Filtrez les SMS indésirables."
        ) {
          showSmsFilterSetupSheet = true
        }
      }

      Divider().padding(.horizontal, 16)

      featureRow(
        icon: "phone.fill",
        title: "Signalement d'appels",
        subtitle: "Signalez les appels indésirables depuis le journal d'appels."
      ) {
        showCallReportingSetupSheet = true
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
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 20))
          .foregroundColor(.secondary)
          .frame(width: 24)
          .accessibilityHidden(true)

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
          .accessibilityHidden(true)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
      .accessibilityElement(children: .combine)
    }
    .buttonStyle(.plain)
  }

  private var notificationRow: some View {
    HStack(spacing: 12) {
      Image(systemName: "bell.badge.fill")
        .font(.system(size: 20))
        .foregroundColor(.secondary)
        .frame(width: 24)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text("Rappel de mise à jour")
          .appFont(.subheadlineMedium)
          .foregroundColor(.primary)
        Text("Notification tous les 15 jours pour garder l'application active.")
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
    .accessibilityElement(children: .combine)
  }
}
