import SwiftUI

struct SettingsNavigationView: View {
  // MARK: - Dependencies
  @ObservedObject var blockerStatus: BlockerStatusViewModel
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  // MARK: - State
  @State private var showingBusinessCodeSheet = false
  @State private var showingReinstallSheet = false
  @State private var showingResetSheet = false
  @State private var bisouTapCount = 0
  @State private var showingDebugSheet = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          Button {
            Task {
              await blockerStatus.openSettings()
            }
          } label: {
            Label(
              "Activer ou désactiver Saracroche dans **Réglages**",
              systemImage: "gearshape.fill"
            )
          }

          Button {
            showingBusinessCodeSheet = true
          } label: {
            Label("Fonctionnalités pour entreprises", systemImage: "building.2.fill")
          }

          Button {
            showingReinstallSheet = true
          } label: {
            Label(
              "Réinitialiser la liste de blocage",
              systemImage: "arrow.clockwise.circle.fill"
            )
          }

          Button {
            showingResetSheet = true
          } label: {
            Label(
              "Réinitialiser l'application",
              systemImage: "trash.fill"
            )
          }
          .foregroundColor(.red)
        } header: {
          Text("Configuration")
            .appFont(.subheadlineSemiBold)
        }

        Section {
          Button {
            if let url = URL(string: "https://saracroche.org/fr/help") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Aide & FAQ", systemImage: "questionmark.circle.fill")
          }

          Button {
            if let url = URL(string: "https://saracroche.org/fr/privacy") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Confidentialité", systemImage: "lock.shield.fill")
          }

          Button {
            if let url = URL(string: "https://saracroche.org") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Site officiel", systemImage: "safari.fill")
          }

          Button {
            if let url = URL(string: "https://saracroche.org/fr/support") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Soutien & dons", systemImage: "heart.fill")
          }

          Button {
            if let url = URL(
              string:
                "https://apps.apple.com/app/id6743679292?action=write-review"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Noter l'application", systemImage: "star.fill")
          }

          Button {
            if let url = URL(
              string: "https://codeberg.org/cbouvat/saracroche-ios"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Label(
              "Code source",
              systemImage: "keyboard.fill"
            )
          }

          Button {
            if let url = URL(string: "https://mastodon.social/@cbouvat") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Mastodon @cbouvat", systemImage: "person.bubble.fill")
          }
        } header: {
          Text("Liens")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Button {
            bisouTapCount += 1
            if bisouTapCount >= 3 {
              showingDebugSheet = true
              bisouTapCount = 0
            }
          } label: {
            VStack(spacing: 8) {
              Text(
                "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
              )
              .padding(.vertical, 4)
              .frame(maxWidth: .infinity)
              .multilineTextAlignment(.center)

              Text("Bisou 😘")
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
          }
          .buttonStyle(.plain)
          .padding(.vertical, 8)
        }
      }
      .appFont(.body)
      .tint(.primary)
      .navigationTitle("Réglages")
      .sheet(isPresented: $showingBusinessCodeSheet) {
        BusinessCodeSheet()
      }
      .sheet(isPresented: $showingReinstallSheet) {
        ReinstallSheet(blockerUpdate: blockerUpdate)
      }
      .sheet(isPresented: $showingResetSheet) {
        ResetSheet(blockerUpdate: blockerUpdate)
      }
      .sheet(isPresented: $showingDebugSheet) {
        DebugSheet()
      }
    }
  }
}

#Preview {
  SettingsNavigationView(
    blockerStatus: BlockerStatusViewModel(),
    blockerUpdate: BlockerUpdateViewModel()
  )
}
