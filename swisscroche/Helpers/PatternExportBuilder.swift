import Foundation

/// Renders the user's patterns as text that `PatternImportParser` reads back verbatim.
///
/// The output is the shareable format: a `//` header, then one entry per line as
/// `+number, name, action`. Exporting and re-importing must round-trip without loss,
/// which is what makes lists shareable between users.
enum PatternExportBuilder {

  /// Entry to export, kept free of CoreData so this stays testable.
  struct Item {
    let pattern: String
    let name: String?
    let action: String

    init(pattern: String, name: String?, action: String) {
      self.pattern = pattern
      self.name = name
      self.action = action
    }
  }

  static let fileExtension = "txt"

  /// Builds the shareable text.
  /// - Parameters:
  ///   - items: Patterns to export, already stripped of removal actions.
  ///   - date: Generation date written in the header.
  static func build(from items: [Item], date: Date = Date()) -> String {
    var lines = [
      "// SwissCroche — liste de blocage partagée",
      "// \(items.count) préfixe\(items.count > 1 ? "s" : "") — exporté le \(headerDate(date))",
      "// Importez ce fichier dans SwissCroche : Listes › Liste personnelle › Importer une liste",
      "",
    ]

    for item in items {
      lines.append(line(for: item))
    }

    return lines.joined(separator: "\n") + "\n"
  }

  /// Filename suggested when sharing, e.g. `swisscroche-liste-2026-08-07.txt`.
  static func filename(date: Date = Date()) -> String {
    "swisscroche-liste-\(headerDate(date)).\(fileExtension)"
  }

  // MARK: - Private

  private static func line(for item: Item) -> String {
    // Patterns are stored without the leading '+', which the format requires.
    let number = item.pattern.hasPrefix("+") ? item.pattern : "+\(item.pattern)"

    // The name field stays present even when empty, so the action keeps its
    // third position and the parser does not mistake it for a name.
    let name = item.name?.trimmingCharacters(in: .whitespaces) ?? ""
    return "\(number), \(name), \(item.action)"
  }

  private static func headerDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter.string(from: date)
  }
}
