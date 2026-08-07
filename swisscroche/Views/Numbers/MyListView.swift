import SwiftUI

struct MyListView: View {
  @ObservedObject var viewModel: ListsViewModel
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  @Environment(\.dismiss) private var dismiss
  @State private var showAddPatternSheet = false
  @State private var showUpdateInProgressSheet = false
  @State private var isLowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
  @State private var showLowPowerAlert: Bool = false

  private func handleUpdateAction() {
    if isLowPowerMode {
      showLowPowerAlert = true
    } else {
      showUpdateInProgressSheet = true
    }
  }

  var body: some View {
    List {
      if viewModel.userPatterns.isEmpty {
        Text("Aucun préfixe personnalisé n'a été ajouté encore.")
          .appFont(.caption)
          .foregroundColor(.secondary)
      } else {
        ForEach(viewModel.userPatterns) { pattern in
          NavigationLink {
            PatternDetailView(pattern: pattern) {
              Task {
                await viewModel.deletePattern(pattern)
              }
            }
          } label: {
            PatternRow(pattern: pattern)
              .foregroundColor(.primary)
          }
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              Task {
                await viewModel.deletePattern(pattern)
              }
            } label: {
              Label("Supprimer", systemImage: "trash.fill")
            }
            .tint(.red)
          }
        }
      }

    }
    .navigationTitle("Liste personnelle")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showAddPatternSheet = true
        } label: {
          Label("Ajouter un préfixe", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $showAddPatternSheet) {
      AddPatternSheet(viewModel: viewModel, isPresented: $showAddPatternSheet)
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
    .onChange(of: viewModel.didModifyPatterns) { didModify in
      if didModify {
        viewModel.didModifyPatterns = false
        handleUpdateAction()
      }
    }
    .lowPowerModeGuard(
      showUpdateInProgressSheet: $showUpdateInProgressSheet,
      showLowPowerAlert: $showLowPowerAlert,
      isLowPowerMode: $isLowPowerMode
    )
  }
}

#Preview {
  NavigationView {
    MyListView(viewModel: ListsViewModel(), blockerUpdate: BlockerUpdateViewModel())
  }
}
