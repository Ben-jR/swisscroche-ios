import SwiftUI

/// ViewModifier that encapsulates all sheet presentations for HomeNavigationView
struct HomeSheetModifier: ViewModifier {
  @ObservedObject var blockerStatus: BlockerStatusViewModel
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel
  @ObservedObject var userPreferences: UserPreferencesViewModel

  @Binding var showDonationSheet: Bool
  @Binding var showInfoSheet: Bool
  @Binding var showUpdateInProgressSheet: Bool
  @Binding var showSmsFilterSetupSheet: Bool
  @Binding var showCallReportingSetupSheet: Bool
  @Binding var showShortcutSetupSheet: Bool

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showDonationSheet) {
        DonationSheet()
      }
      .sheet(isPresented: $showInfoSheet) {
        InfoSheet(blockerUpdate: blockerUpdate, blockerStatus: blockerStatus)
      }
      .sheet(
        isPresented: $showUpdateInProgressSheet,
        onDismiss: {
          Task {
            await blockerUpdate.loadData()
          }
        }
      ) {
        UpdateInProgressSheet(blockerUpdate: blockerUpdate)
      }
      .sheet(isPresented: $blockerUpdate.showUpdateError) {
        UpdateErrorSheet(blockerUpdate: blockerUpdate)
      }
      .sheet(isPresented: $showSmsFilterSetupSheet) {
        if #available(iOS 16.0, *) {
          SmsFilterSetupSheet(
            blockerStatus: blockerStatus,
            userPreferences: userPreferences
          )
        }
      }
      .sheet(isPresented: $showCallReportingSetupSheet) {
        CallReportingSetupSheet(
          blockerStatus: blockerStatus,
          userPreferences: userPreferences
        )
      }
      .sheet(isPresented: $showShortcutSetupSheet) {
        if #available(iOS 16.0, *) {
          ShortcutSetupSheet(userPreferences: userPreferences)
        }
      }
  }
}
