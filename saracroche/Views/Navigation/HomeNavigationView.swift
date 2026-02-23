import SwiftUI

struct HomeNavigationView: View {
  // MARK: - Dependencies
  @ObservedObject var blockerStatus: BlockerStatusViewModel
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel
  @ObservedObject var userPreferences: UserPreferencesViewModel

  // MARK: - Environment
  @Environment(\.scenePhase) private var scenePhase

  // MARK: - State
  @State private var showDonationSheet = false
  @State private var showInfoSheet = false
  @State private var showUpdateInProgressSheet = false
  @State private var showSmsFilterSetupSheet = false
  @State private var showCallReportingSetupSheet = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          if blockerStatus.blockerExtensionStatus == .enabled {
            if blockerUpdate.completedPatternsCount == 0 {
              HomeInstallCard(
                showUpdateInProgressSheet: $showUpdateInProgressSheet
              )
            } else if hasAvailableUpdate {
              HomeUpdateCard(showUpdateInProgressSheet: $showUpdateInProgressSheet)
            } else {
              HomeActiveCard(
                totalPhoneNumbersCount: blockerUpdate.totalPhoneNumbersCount,
                showInfoSheet: $showInfoSheet
              )
              HomeFeatureCards(
                userPreferences: userPreferences,
                showSmsFilterSetupSheet: $showSmsFilterSetupSheet,
                showCallReportingSetupSheet: $showCallReportingSetupSheet,
                showDonationSheet: $showDonationSheet
              )
            }
          } else {
            HomeDisabledCard(blockerStatus: blockerStatus)
          }
        }
        .padding()
      }
      .navigationTitle("Saracroche")
      .onAppear {
        Task {
          await handleActivation()
        }
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          Task {
            await handleActivation()
          }
        }
      }
      .modifier(
        HomeSheetModifier(
          blockerStatus: blockerStatus,
          blockerUpdate: blockerUpdate,
          userPreferences: userPreferences,
          showDonationSheet: $showDonationSheet,
          showInfoSheet: $showInfoSheet,
          showUpdateInProgressSheet: $showUpdateInProgressSheet,
          showSmsFilterSetupSheet: $showSmsFilterSetupSheet,
          showCallReportingSetupSheet: $showCallReportingSetupSheet
        )
      )
    }
  }

  // MARK: - Lifecycle

  private func handleActivation() async {
    await blockerStatus.checkBlockerExtensionStatus()
    await blockerStatus.checkBackgroundStatus()
    await blockerUpdate.loadData()
    await userPreferences.loadPreferences()
    await blockerUpdate.downloadListOnLaunch()
  }

  private var hasAvailableUpdate: Bool {
    blockerUpdate.shouldUpdateList || blockerUpdate.pendingPatternsCount > 0
  }
}
