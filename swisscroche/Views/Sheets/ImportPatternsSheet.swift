import SwiftUI
import UniformTypeIdentifiers

/// Lets the user bulk-import numbers or prefixes from pasted text or a text file.
struct ImportPatternsSheet: View {
  // MARK: - Dependencies
  @ObservedObject var viewModel: ListsViewModel
  @Binding var isPresented: Bool

  // MARK: - State
  @State private var text: String = ""
  @State private var isBlock: Bool = true
  @State private var summary: ListsViewModel.ImportSummary?
  @State private var showFileImporter = false
  @State private var fileError: String?
  @FocusState private var isTextEditorFocused: Bool

  private var hasContent: Bool {
    !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          if let summary {
            summaryView(summary)
          } else {
            inputView
          }
        }
        .padding()
      }
      .navigationTitle(summary == nil ? "Importer une liste" : "Résultat de l'import")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          if summary == nil {
            Button("Annuler") { isPresented = false }
          }
        }
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Terminé") { isTextEditorFocused = false }
            .appFont(.bodyBold)
        }
      }
      .fileImporter(
        isPresented: $showFileImporter,
        allowedContentTypes: [.plainText, .commaSeparatedText, .text]
      ) { result in
        loadFile(result)
      }
    }
  }

  // MARK: - Input

  private var inputView: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Numéros à importer")
          .appFont(.subheadlineSemiBold)

        TextEditor(text: $text)
          .appFont(.body)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)
          .focused($isTextEditorFocused)
          .frame(minHeight: 180)
          .padding(8)
          .background(Color(.systemBackground))
          .cornerRadius(16)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(
                isTextEditorFocused ? Color("AppColor") : Color(.systemGray4),
                lineWidth: 1
              )
          )
          .accessibilityLabel("Liste de numéros à importer")

        Text(
          "Un numéro par ligne, au format international. Un nom peut suivre après une virgule. "
            + "Les lignes commençant par « // » sont ignorées. L'action choisie ci-dessous "
            + "s'applique, sauf aux lignes qui précisent la leur."
        )
        .appFont(.caption)
        .foregroundColor(.secondary)

        Text(
          "+41791234567\n+41791234####, Démarchage\n+41221234567, Sondage, identify\n// un commentaire"
        )
        .appFont(.caption)
        .foregroundColor(.secondary)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
        )
        .accessibilityHidden(true)

        if let fileError {
          Text(fileError)
            .appFont(.caption)
            .foregroundColor(.red)
        }
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Action")
          .appFont(.subheadlineSemiBold)
        ReportChoiceButton(
          title: "Bloquer",
          description: "Bloquer les appels correspondants.",
          icon: "xmark.circle.fill",
          isSelected: isBlock,
          color: .red,
          action: { isBlock = true }
        )
        ReportChoiceButton(
          title: "Identifier",
          description: "Identifier les appels correspondants.",
          icon: "info.circle.fill",
          isSelected: !isBlock,
          color: .blue,
          action: { isBlock = false }
        )
      }

      VStack(spacing: 12) {
        Button {
          isTextEditorFocused = false
          Task {
            summary = await viewModel.importPatterns(
              from: text,
              action: isBlock ? "block" : "identify"
            )
          }
        } label: {
          HStack {
            Image(systemName: "square.and.arrow.down.fill")
            Text("Importer")
          }
        }
        .buttonStyle(.fullWidth(background: Color("AppColor"), foreground: .black))
        .disabled(!hasContent || viewModel.isLoading)

        Button {
          fileError = nil
          showFileImporter = true
        } label: {
          Label("Choisir un fichier", systemImage: "doc.fill")
        }
        .buttonStyle(.fullWidth(background: Color.gray.opacity(0.2), foreground: .primary))
      }
    }
  }

  // MARK: - Summary

  private func summaryView(_ summary: ListsViewModel.ImportSummary) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack(spacing: 16) {
        Image(
          systemName: summary.added > 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
        )
        .font(.system(size: 60))
        .foregroundColor(summary.added > 0 ? .green : .orange)
        .accessibilityHidden(true)

        Text(
          summary.added > 0
            ? "\(summary.added) préfixe\(summary.added > 1 ? "s" : "") importé\(summary.added > 1 ? "s" : "")"
            : "Aucun préfixe importé"
        )
        .appFont(.titleBold)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
      }

      VStack(alignment: .leading, spacing: 12) {
        summaryRow(
          icon: "plus.circle.fill", color: .green, label: "Importés", count: summary.added)
        if summary.duplicates > 0 {
          summaryRow(
            icon: "doc.on.doc.fill", color: .orange, label: "Déjà présents",
            count: summary.duplicates)
        }
        if summary.overlaps > 0 {
          summaryRow(
            icon: "arrow.triangle.merge", color: .orange, label: "Plages qui se chevauchent",
            count: summary.overlaps)
        }
        if !summary.invalid.isEmpty {
          summaryRow(
            icon: "xmark.circle.fill", color: .red, label: "Ignorés (format invalide)",
            count: summary.invalid.count)
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.1))
      )

      if !summary.invalid.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text("Lignes ignorées")
            .appFont(.subheadlineSemiBold)
          ForEach(Array(summary.invalid.prefix(10).enumerated()), id: \.offset) { _, item in
            VStack(alignment: .leading, spacing: 2) {
              Text(item.pattern)
                .appFont(.caption)
                .foregroundColor(.primary)
              Text(item.reason)
                .appFont(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
          }
          if summary.invalid.count > 10 {
            Text("… et \(summary.invalid.count - 10) autre(s).")
              .appFont(.caption)
              .foregroundColor(.secondary)
          }
        }
      }

      Button {
        // Only now flag the change, so the update sheet opens after this one closes.
        if summary.added > 0 {
          viewModel.didModifyPatterns = true
        }
        isPresented = false
      } label: {
        Label("Terminer", systemImage: "checkmark")
      }
      .buttonStyle(.fullWidth(background: Color("AppColor"), foreground: .black))
    }
  }

  private func summaryRow(icon: String, color: Color, label: String, count: Int) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(color)
        .frame(width: 24)
        .accessibilityHidden(true)
      Text(label)
        .appFont(.subheadlineMedium)
      Spacer()
      Text("\(count)")
        .appFont(.bodyBold)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(label): \(count)")
  }

  // MARK: - File Import

  private func loadFile(_ result: Result<URL, Error>) {
    switch result {
    case .success(let url):
      // Files picked outside the sandbox need explicit access.
      let needsRelease = url.startAccessingSecurityScopedResource()
      defer {
        if needsRelease { url.stopAccessingSecurityScopedResource() }
      }
      do {
        let contents = try String(contentsOf: url, encoding: .utf8)
        text = contents
        fileError = nil
      } catch {
        fileError = "Impossible de lire le fichier. Vérifiez qu'il s'agit d'un fichier texte."
      }
    case .failure:
      fileError = "Impossible d'ouvrir le fichier."
    }
  }
}

#Preview {
  ImportPatternsSheet(viewModel: ListsViewModel(), isPresented: .constant(true))
}
