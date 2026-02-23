import SwiftUI

struct DebugSheet: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var alertMessage: String?
  @State private var showAlert = false

  // MARK: - Computed Properties
  private var deviceIdentifier: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2.0)))
            } else {
              Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            }

            Text("Debug")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 16) {
              HStack(spacing: 12) {
                Image(systemName: "iphone.circle.fill")
                  .font(.system(size: 20))
                  .foregroundColor(.blue)
                  .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                  Text("UUID Device")
                    .appFont(.subheadlineMedium)
                    .foregroundColor(.primary)

                  Text(deviceIdentifier)
                    .appFont(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                }

                Spacer()
              }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            )

            DebugButton(
              action: {
                forceUpdate()
              },
              title: "Force update",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                downloadList()
              },
              title: "Download list",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                convertList()
              },
              title: "Update list",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                Task {
                  await clearCoreData()
                }
              },
              title: "Clear CoreData",
              background: .red,
              foreground: .white
            )

            DebugButton(
              action: {
                resetUserDefaults()
              },
              title: "Reset UserDefaults",
              background: .red,
              foreground: .white
            )
          }
        }
      }
      .padding()
      .toolbar {
        ToolbarItem {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
    .alert("Operation Result", isPresented: $showAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage ?? "Operation completed")
    }
  }

  private func downloadList() {
    Task {
      do {
        let jsonResponse = try await ListAPIService().downloadFrenchList()
        DispatchQueue.main.async {
          alertMessage =
            "✅ Download successful: version \(jsonResponse["version"] as? String ?? "unknown")"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Download failed: \(error.localizedDescription)"
          showAlert = true
        }
      }
    }
  }

  private func forceUpdate() {
    Task {
      do {
        try await BlockerService().performBackgroundUpdate()
        DispatchQueue.main.async {
          alertMessage = "✅ Update forced"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Update failed: \(error.localizedDescription)"
          showAlert = true
        }
      }
    }
  }

  private func convertList() {
    Task {
      do {
        let listService = ListService()
        try await listService.update()
        DispatchQueue.main.async {
          alertMessage = "✅ Conversion successful"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Conversion failed: \(error.localizedDescription)"
          showAlert = true
        }
      }
    }
  }

  private func resetUserDefaults() {
    UserDefaultsService().resetAllData()
    alertMessage = "✅ UserDefaults reset"
    showAlert = true
  }

  private func clearCoreData() async {
    let patternService = PatternService()
    await patternService.deleteAllPatterns()
    alertMessage = "✅ CoreData cleared"
    showAlert = true
  }
}

struct DebugButton: View {
  let action: () -> Void
  let title: String
  let background: Color
  let foreground: Color

  var body: some View {
    Button(action: action) {
      Text(title)
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(background)
        .foregroundColor(foreground)
        .appFont(.bodyBold)
        .cornerRadius(24)
    }
  }
}

#Preview {
  DebugSheet()
}
