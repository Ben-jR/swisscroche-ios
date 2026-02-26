import SwiftUI

/// View model for user preferences (notifications, card dismissals)
@MainActor
class UserPreferencesViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var isNotificationReminderEnabled: Bool = false
  @Published var isSmsFilterSetupDismissed: Bool = false
  @Published var isCallReportingSetupDismissed: Bool = false
  @Published var isShortcutSetupDismissed: Bool = false

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

    isSmsFilterSetupDismissed = userDefaults.getSmsFilterSetupDismissed()
    isCallReportingSetupDismissed = userDefaults.getCallReportingSetupDismissed()
    isShortcutSetupDismissed = userDefaults.getShortcutSetupDismissed()
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

  /// Dismisses the SMS filter setup card
  func dismissSmsFilterSetup() {
    userDefaults.setSmsFilterSetupDismissed(true)
    isSmsFilterSetupDismissed = true
  }

  /// Dismisses the call reporting setup card
  func dismissCallReportingSetup() {
    userDefaults.setCallReportingSetupDismissed(true)
    isCallReportingSetupDismissed = true
  }

  /// Dismisses the shortcut setup card
  func dismissShortcutSetup() {
    userDefaults.setShortcutSetupDismissed(true)
    isShortcutSetupDismissed = true
  }
}
