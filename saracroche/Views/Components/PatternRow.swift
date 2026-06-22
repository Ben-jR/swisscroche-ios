import SwiftUI

struct PatternRow: View {
  @ObservedObject var pattern: Pattern

  private var patternName: String {
    pattern.name ?? ""
  }

  private var calculateBlockedCountFromPattern: Int64 {
    ListsViewModel.calculateBlockedCount(pattern)
  }

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize: DynamicTypeSize

  var body: some View {
    HStack(alignment: .center, spacing: 6) {
      Image(systemName: actionIcon)
        .appFont(.body)
        .foregroundColor(actionColor)

      VStack(alignment: .leading) {

        // If not big text sizes, keep usual layout
        if !dynamicTypeSize.isLargeTextUsed {
          // Name and blocked numbers count
          HStack {
            if !patternName.isEmpty {
              Text(patternName)
                .appFont(.captionSemiBold)
            }
            Spacer()
            Text("\(calculateBlockedCountFromPattern) numéros")
              .appFont(.caption2)
              .foregroundColor(.secondary)
          }
          // Big text sizes in use, prefer pure vertical layout
        } else {
          if let name = pattern.name, !name.isEmpty {
            Text(name)
              .appFont(.captionSemiBold)
          }
          Spacer()
          Text("\(calculateBlockedCountFromPattern) numéros")
            .appFont(.caption2)
            .foregroundColor(.secondary)
        }

        // Pattern string
        Text(ListsViewModel.displayPattern(pattern.pattern))
          .font(.caption.monospaced())
          .foregroundColor(.secondary)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      "\(patternName) : \(ListsViewModel.displayPattern(pattern.pattern)), action: \(actionLabel), \(ListsViewModel.spelledOut(calculateBlockedCountFromPattern)) numéros bloqués"
    )
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
    case "block": return "bloquer"
    case "identify": return "identifier"
    default: return "unknown"
    }
  }
}
