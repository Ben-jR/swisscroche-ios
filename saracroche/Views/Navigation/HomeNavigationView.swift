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
  @State private var showShortcutSetupSheet = false
  @State private var isLoading = true
  @State private var hasInitiallyLoaded = false
  @State private var loadingStep = "Démarrage..."

  var body: some View {
    NavigationView {
      ScrollView {
        if isLoading && !hasInitiallyLoaded {
          HomeLoadingCard(loadingStep: loadingStep)
            .padding()
        } else {
          VStack(spacing: 16) {
            if blockerStatus.blockerExtensionStatus == .enabled {
              if blockerUpdate.lastSuccessfulUpdateAt == nil {
                HomeInstallCard(
                  showUpdateInProgressSheet: $showUpdateInProgressSheet
                )
              } else if blockerUpdate.shouldUpdateList
                || blockerUpdate.pendingPatternsCount > 0
                || blockerUpdate.iosVersionChanged
              {
                HomeUpdateCard(showUpdateInProgressSheet: $showUpdateInProgressSheet)
              } else {
                HomeActiveCard(
                  totalPhoneNumbersCount: blockerUpdate.totalPhoneNumbersCount,
                  showInfoSheet: $showInfoSheet
                )
                HomeFeatureCards(
                  userPreferences: userPreferences,
                  showShortcutSetupSheet: $showShortcutSetupSheet,
                  showSmsFilterSetupSheet: $showSmsFilterSetupSheet,
                  showCallReportingSetupSheet: $showCallReportingSetupSheet
                )
                HomeDonationCard(
                  userPreferences: userPreferences,
                  showDonationSheet: $showDonationSheet
                )
              }
            } else {
              HomeDisabledCard(blockerStatus: blockerStatus)
            }
          }
          .padding()
        }
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
          showCallReportingSetupSheet: $showCallReportingSetupSheet,
          showShortcutSetupSheet: $showShortcutSetupSheet
        )
      )
    }
  }

  // MARK: - Lifecycle

  private func handleActivation() async {
    isLoading = true
    loadingStep = "Vérification de l'extension…"
    await blockerStatus.checkBlockerExtensionStatus()
    loadingStep = "Vérification des autorisations…"
    await blockerStatus.checkBackgroundStatus()
    loadingStep = "Chargement des données…"
    await blockerUpdate.loadData()
    loadingStep = "Chargement des préférences…"
    await userPreferences.loadPreferences()
    loadingStep = "Mise à jour de la liste…"
    await blockerUpdate.downloadListOnLaunch()
    isLoading = false
    hasInitiallyLoaded = true
  }
}
