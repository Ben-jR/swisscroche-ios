import SwiftUI

struct ListsNavigationView: View {
  // MARK: - Dependencies
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel
  @StateObject private var viewModel = ListsViewModel()

  var body: some View {
    NavigationView {
      Form {
        // SECTION 1: List
        Section {
          if viewModel.apiPatterns.isEmpty {
            VStack {
              Text("La liste sera téléchargée automatiquement.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }
          } else {
            NavigationLink {
              APIPatternListView(patterns: viewModel.apiPatterns)
            } label: {
              VStack(alignment: .leading, spacing: 8) {
                // List name
                Text(viewModel.frenchListName)
                  .appFont(.headline)

                // Version
                HStack(spacing: 4) {
                  Image(systemName: "tag.circle.fill")
                    .appFont(.body)
                    .foregroundColor(.primary)
                  Text("Version du " + viewModel.frenchListVersion)
                    .appFont(.caption)
                    .foregroundColor(.secondary)
                }

                // Blocked numbers count
                HStack(spacing: 4) {
                  Image(systemName: "number.circle.fill")
                    .appFont(.body)
                    .foregroundColor(.primary)
                  Text("\(viewModel.frenchListBlockedCount) numéros")
                    .appFont(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(
                      "\(ListsViewModel.spelledOut(Int64(viewModel.frenchListBlockedCount))) numéros bloqués"
                    )
                }
              }
            }
          }
        } header: {
          Text("Liste")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Text(
            "Liste téléchargée automatiquement et mise à jour régulièrement."
          )
          .appFont(.caption)
        }

        // SECTION 2: My list
        Section {
          NavigationLink {
            MyListView(viewModel: viewModel, blockerUpdate: blockerUpdate)
          } label: {
            VStack(alignment: .leading, spacing: 8) {
              Text("Liste personnelle")
                .appFont(.headline)

              HStack(spacing: 4) {
                Image(systemName: "number.circle.fill")
                  .appFont(.body)
                  .foregroundColor(.primary)
                Text(
                  "\(viewModel.userPatternsNumberCount) \(viewModel.userPatternsNumberCount > 1 ? "numéros" : "numéro")"
                )
                .appFont(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel(
                  "\(ListsViewModel.spelledOut(viewModel.userPatternsNumberCount)) numéros")
              }
            }
          }
        } header: {
          Text("Liste personnelle")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Text(
            "Ajoutez vos propres préfixes pour les bloquer ou les identifier."
          )
          .appFont(.caption)
        }
      }
      .navigationTitle("Listes")
      .onAppear {
        Task {
          await viewModel.loadData()
        }
      }
    }
  }
}

#Preview {
  ListsNavigationView(blockerUpdate: BlockerUpdateViewModel())
}
