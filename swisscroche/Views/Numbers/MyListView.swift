import SwiftUI

struct MyListView: View {
  @ObservedObject var viewModel: ListsViewModel
  @ObservedObject var blockerUpdate: BlockerUpdateViewModel

  @Environment(\.dismiss) private var dismiss
  @State private var showAddPatternSheet = false
  @State private var showImportSheet = false
  @State private var showUpdateInProgressSheet = false
  @State private var isLowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
  @State private var showLowPowerAlert: Bool = false
  @State private var exportFile: ExportFile?
  @State private var showExportError = false

  /// `sheet(item:)` needs an Identifiable, and URL isn't one.
  private struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
  }

  private func shareList() {
    guard let url = viewModel.exportUserPatternsToFile() else {
      showExportError = true
      return
    }
    exportFile = ExportFile(url: url)
  }

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
        Menu {
          Button {
            showAddPatternSheet = true
          } label: {
            Label("Ajouter un préfixe", systemImage: "plus")
          }
          Button {
            showImportSheet = true
          } label: {
            Label("Importer une liste", systemImage: "square.and.arrow.down")
          }
          Button {
            shareList()
          } label: {
            Label("Partager ma liste", systemImage: "square.and.arrow.up")
          }
          .disabled(viewModel.userPatterns.isEmpty)
        } label: {
          Label("Ajouter", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $showAddPatternSheet) {
      AddPatternSheet(viewModel: viewModel, isPresented: $showAddPatternSheet)
    }
    .sheet(isPresented: $showImportSheet) {
      ImportPatternsSheet(viewModel: viewModel, isPresented: $showImportSheet)
    }
    .sheet(item: $exportFile) { file in
      ShareSheet(items: [file.url])
    }
    .alert("Export impossible", isPresented: $showExportError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Le fichier n'a pas pu être créé. Réessayez.")
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
