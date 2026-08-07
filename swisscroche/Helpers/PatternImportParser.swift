import Foundation

/// Parses a pasted or imported text list into pattern entries.
///
/// One entry per line. An optional name may follow the number, separated by a
/// comma, a semicolon or a tab:
///
/// ```
/// // Ma liste
/// +41791234567
/// +41791234####,Spam Marketing
/// +41 44 123 45 67; Démarchage
/// ```
///
/// Whitespace inside a number is stripped, so numbers copied in their readable
/// form are accepted. Parsing is purely syntactic — validating that a pattern is
/// usable is the caller's job.
enum PatternImportParser {

  struct Entry: Equatable {
    let pattern: String
    let name: String?
  }

  private static let separators: Set<Character> = [",", ";", "\t"]
  private static let commentPrefix = "//"

  /// Splits raw text into entries, skipping blank lines and `//` comments.
  static func parse(_ text: String) -> [Entry] {
    text.split(whereSeparator: \.isNewline).compactMap { entry(from: String($0)) }
  }

  private static func entry(from line: String) -> Entry? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !trimmed.hasPrefix(commentPrefix) else { return nil }

    let rawPattern: Substring
    let rawName: Substring?
    if let separatorIndex = trimmed.firstIndex(where: { separators.contains($0) }) {
      rawPattern = trimmed[..<separatorIndex]
      rawName = trimmed[trimmed.index(after: separatorIndex)...]
    } else {
      rawPattern = trimmed[...]
      rawName = nil
    }

    // Numbers are often pasted in readable form ("+41 79 123 45 67").
    let pattern = rawPattern.filter { !$0.isWhitespace }
    guard !pattern.isEmpty else { return nil }

    let name = rawName?.trimmingCharacters(in: .whitespaces)
    return Entry(pattern: pattern, name: (name?.isEmpty ?? true) ? nil : name)
  }
}
