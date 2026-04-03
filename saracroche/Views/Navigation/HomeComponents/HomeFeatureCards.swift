import SwiftUI

struct HomeFeatureCards: View {
  @ObservedObject var userPreferences: UserPreferencesViewModel
  @Binding var showSmsFilterSetupSheet: Bool
  @Binding var showCallReportingSetupSheet: Bool
  @Binding var showShortcutSetupSheet: Bool
  @Binding var showDonationSheet: Bool

  var body: some View {
    Group {
      if #available(iOS 16.0, *) {
        if !userPreferences.isSmsFilterSetupDismissed {
          smsFilterSetupView
        }
      }

      if !userPreferences.isCallReportingSetupDismissed {
        callReportingSetupView
      }

      if !userPreferences.isNotificationReminderEnabled {
        notificationReminderView
      }

      if #available(iOS 16.0, *) {
        if !userPreferences.isShortcutSetupDismissed {
          shortcutSetupView
        }
      }

      if !userPreferences.isDonationDismissed {
        donationView
      }
    }
  }

  private var smsFilterSetupView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Filtre SMS")
        .appFont(.headlineSemiBold)

      Text(
        "Activez le filtre SMS pour que Saracroche filtre automatiquement les messages indésirables."
      )
      .appFont(.body)

      Button {
        showSmsFilterSetupSheet = true
      } label: {
        HStack {
          Image(systemName: "message.fill")
          Text("Configurer")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
      .accessibilityLabel("Configurer le filtre SMS")
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  private var callReportingSetupView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Signalement d'appels")
        .appFont(.headlineSemiBold)

      Text(
        "Activez le signalement pour pouvoir signaler les appels indésirables directement depuis l'historique d'appels."
      )
      .appFont(.body)

      Button {
        showCallReportingSetupSheet = true
      } label: {
        HStack {
          Image(systemName: "phone.fill")
          Text("Configurer")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
      .accessibilityLabel("Configurer le signalement d'appels")
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  private var notificationReminderView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Rappel de mise à jour")
        .appFont(.headlineSemiBold)

      Text(
        "Recevez une notification tous les 15 jours pour vous rappeler "
          + "d'ouvrir l'application, la garder active et mettre à jour la liste de blocage."
      )
      .appFont(.body)

      Button {
        Task {
          await userPreferences.enableNotificationReminder()
        }
      } label: {
        HStack {
          Image(systemName: "bell.badge.fill")
          Text("Activez le rappel")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
      .accessibilityLabel("Activez le rappel de mise à jour")
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  @available(iOS 16.0, *)
  private var shortcutSetupView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Raccourci automatique")
        .appFont(.headlineSemiBold)

      Text(
        "Créez un raccourci pour mettre à jour automatiquement la liste de blocage tous les jours."
      )
      .appFont(.body)

      Button {
        showShortcutSetupSheet = true
      } label: {
        HStack {
          Image(systemName: "arrow.clockwise.circle.fill")
          Text("Configurer")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
      .accessibilityLabel("Configurer le raccourci automatique")
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  private var donationView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Soutenez Saracroche")
        .appFont(.headlineSemiBold)

      Text(
        "Saracroche est une application entièrement gratuite, open source et sans publicité. "
          + "Elle vit grâce aux dons de ses utilisateurs pour continuer à évoluer."
      )
      .appFont(.body)

      Button {
        showDonationSheet = true
      } label: {
        HStack {
          Image(systemName: "heart.fill")
          Text("Soutenez")
        }
      }
      .buttonStyle(
        .fullWidth(background: Color.red, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }
}
