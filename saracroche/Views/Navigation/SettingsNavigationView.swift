import SwiftUI

struct SettingsNavigationView: View {

  private static let bigBisousMagicCount = 3  // ( ˶˘ ³˘)♡

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
              "Activer ou désactiver SwissCroche dans **Réglages**",
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
          // TODO: replace with SwissCroche's own help/privacy/website/support/App Store links once available.
          Button {
            if let url = URL(
              string: "https://codeberg.org/cbouvat/saracroche-ios"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Label(
              "Projet original (upstream)",
              systemImage: "keyboard.fill"
            )
          }
          .accessibilityRemoveTraits(.isButton)
          .accessibilityAddTraits(.isLink)

        } header: {
          Text("Liens")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Button {
            bisouTapCount += 1
            if bisouTapCount >= Self.bigBisousMagicCount {
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
                .accessibilityHidden(true)
            }
          }
          .buttonStyle(.plain)
          .padding(.vertical, 8)
          .accessibilityHint(
            "Tapez \(Self.bigBisousMagicCount) fois pour ouvrir le menu de débogage")
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
