import SwiftUI

/// View model for user preferences (notifications, card dismissals)
@MainActor
class UserPreferencesViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var isNotificationReminderEnabled: Bool = false
  @Published var isDonationDismissed: Bool = false

  // MARK: - Dependencies

  private let userDefaults: UserDefaultsService
  private let notificationService: NotificationService

  // MARK: - Initialization

  init(
    userDefaults: UserDefaultsService = UserDefaultsService(),
    notificationService: NotificationService? = nil
  ) {
    self.userDefaults = userDefaults
    self.notificationService =
      notificationService ?? NotificationService(userDefaults: userDefaults)
  }

  // MARK: - Data Loading

  func loadPreferences() async {
    isNotificationReminderEnabled = userDefaults.getNotificationReminderEnabled()
    await notificationService.syncReminderStateOnLaunch()
    isNotificationReminderEnabled = userDefaults.getNotificationReminderEnabled()

    isDonationDismissed = userDefaults.isDonationDismissed()
  }

  // MARK: - Notifications

  /// Enables the notification reminder after requesting permission
  func enableNotificationReminder() async {
    let granted = await notificationService.requestAuthorization()
    if granted {
      await notificationService.scheduleReminderNotification()
      userDefaults.setNotificationReminderEnabled(true)
      isNotificationReminderEnabled = true
    }
  }

  /// Disables the notification reminder
  func disableNotificationReminder() {
    notificationService.cancelReminderNotification()
    userDefaults.setNotificationReminderEnabled(false)
    isNotificationReminderEnabled = false
  }

  // MARK: - Card Dismissals

  /// Dismisses the donation card for 20 days
  func dismissDonation() {
    userDefaults.setDonationDismissedAt(Date())
    isDonationDismissed = true
  }
}
