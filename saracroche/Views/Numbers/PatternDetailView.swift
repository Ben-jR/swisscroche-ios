import SwiftUI

struct PatternDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var pattern: Pattern
  let onDelete: () -> Void

  var body: some View {
    List {
      Section {
        HStack {
          Text("Préfixe")
            .appFont(.body)
          Spacer()
          Text(pattern.pattern ?? "")
            .font(.body.monospaced())
            .foregroundColor(.secondary)
        }

        HStack {
          Text("Premier numéro")
            .appFont(.body)
          Spacer()
          Text(firstNumber)
            .font(.body.monospaced())
            .foregroundColor(.secondary)
        }

        HStack {
          Text("Dernier numéro")
            .appFont(.body)
          Spacer()
          Text(lastNumber)
            .font(.body.monospaced())
            .foregroundColor(.secondary)
        }

        HStack {
          Text("Numéros concernés")
            .appFont(.body)
          Spacer()
          Text("\(numberCount)")
            .appFont(.body)
            .foregroundColor(.secondary)
        }

        HStack {
          Text("Action")
            .appFont(.body)
          Spacer()
          HStack(spacing: 4) {
            Image(systemName: actionIcon)
              .foregroundColor(actionColor)
            Text(actionLabel)
              .appFont(.body)
              .foregroundColor(.secondary)
          }
        }

        if let addedDate = pattern.addedDate {
          HStack {
            Text("Ajouté le")
              .appFont(.body)
            Spacer()
            Text(addedDate, style: .date)
              .appFont(.body)
              .foregroundColor(.secondary)
          }
        }
      } header: {
        Text("Préfixe")
          .appFont(.subheadlineSemiBold)
      }

    }
    .navigationTitle(pattern.name ?? pattern.pattern ?? "Détail")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          onDelete()
          dismiss()
        } label: {
          Label("Supprimer le préfixe", systemImage: "trash")
            .foregroundColor(.red)
        }
      }
    }
  }

  private var actionIcon: String {
    switch pattern.action {
    case "block": return "xmark.circle.fill"
    case "identify": return "info.circle.fill"
    default: return "questionmark.circle.fill"
    }
  }

  private var actionColor: Color {
    switch pattern.action {
    case "block": return .red
    case "identify": return .blue
    default: return .gray
    }
  }

  private var actionLabel: String {
    switch pattern.action {
    case "block": return "Bloquer"
    case "identify": return "Identifier"
    default: return "Inconnu"
    }
  }

  private var numberCount: Int64 {
    guard let patternString = pattern.pattern else { return 0 }
    return PhoneNumberHelpers.countPhoneNumbers(for: patternString)
  }

  private var firstNumber: String {
    guard let patternString = pattern.pattern else { return "" }
    return patternString.replacingOccurrences(of: "#", with: "0")
  }

  private var lastNumber: String {
    guard let patternString = pattern.pattern else { return "" }
    return patternString.replacingOccurrences(of: "#", with: "9")
  }
}
