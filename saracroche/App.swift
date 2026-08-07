import BackgroundTasks
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Register background update task
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: AppConstants.backgroundServiceIdentifier,
      using: nil
    ) { task in
      guard let processingTask = task as? BGProcessingTask else {
        task.setTaskCompleted(success: false)
        return
      }
      BackgroundService.shared.handleBackgroundUpdate(task: processingTask)
    }

    // Register health check background task
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: AppConstants.healthCheckServiceIdentifier,
      using: nil
    ) { task in
      guard let processingTask = task as? BGProcessingTask else {
        task.setTaskCompleted(success: false)
        return
      }
      HealthCheckService.shared.handleBackgroundHealthCheck(task: processingTask)
    }

    // Start health check service after handlers are registered
    HealthCheckService.shared.start()

    return true
  }
}

@main
struct SwissCrocheApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  init() {
    // Load MDM configuration at app launch
    loadMDMConfiguration()
    let boldFontName = "AtkinsonHyperlegibleNextVFLight-Bold"
    let regularFontName = "AtkinsonHyperlegibleNextVFLight-Regular"

    // Navigation bar
    let navAppearance = UINavigationBarAppearance()
    navAppearance.configureWithDefaultBackground()
    if let boldFont = UIFont(name: boldFontName, size: 34) {
      navAppearance.largeTitleTextAttributes = [.font: boldFont, .foregroundColor: UIColor.label]
    }
    if let boldFont = UIFont(name: boldFontName, size: 17) {
      navAppearance.titleTextAttributes = [.font: boldFont, .foregroundColor: UIColor.label]
    }
    UINavigationBar.appearance().standardAppearance = navAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    UINavigationBar.appearance().tintColor = .label

    // Tab bar
    let tabAppearance = UITabBarItemAppearance()
    if let font = UIFont(name: regularFontName, size: 10) {
      tabAppearance.normal.titleTextAttributes = [.font: font]
      tabAppearance.selected.titleTextAttributes = [.font: font]
    }
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithDefaultBackground()
    tabBarAppearance.stackedLayoutAppearance = tabAppearance
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
  }

  // MARK: - MDM Configuration

  private func loadMDMConfiguration() {
    let mdmService = MDMConfigurationService()
    let hasNewKey = mdmService.loadConfiguration()

    if hasNewKey {
      Logger.info("MDM configuration loaded with API key", category: .mdm)
    }
  }

  var body: some Scene {
    WindowGroup {
      SwissCrocheView()
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .background {
        BackgroundService.shared.applicationDidEnterBackground()
      }
    }
  }
}
