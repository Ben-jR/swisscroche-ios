import SwiftUI

struct SwissCrocheView: View {
  @StateObject private var blockerStatus = BlockerStatusViewModel()
  @StateObject private var blockerUpdate = BlockerUpdateViewModel()
  @StateObject private var userPreferences = UserPreferencesViewModel()

  var body: some View {
    TabView {
      HomeNavigationView(
        blockerStatus: blockerStatus,
        blockerUpdate: blockerUpdate,
        userPreferences: userPreferences
      )
      .tabItem {
        Label("Accueil", systemImage: "house.fill")
      }
      ReportNavigationView()
        .tabItem {
          Label("Signaler", systemImage: "megaphone.fill")
        }
      ListsNavigationView(blockerUpdate: blockerUpdate)
        .tabItem {
          Label("Listes", systemImage: "number.square.fill")
        }
      SettingsNavigationView(
        blockerStatus: blockerStatus,
        blockerUpdate: blockerUpdate
      )
      .tabItem {
        Label("Réglages", systemImage: "gearshape.fill")
      }
    }
    .tint(.primary)
  }
}

#Preview {
  SwissCrocheView()
}
