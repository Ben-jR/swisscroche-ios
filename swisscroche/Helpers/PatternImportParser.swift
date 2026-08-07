import Foundation

/// Parses a pasted, imported or shared text list into pattern entries.
///
/// One entry per line: the number, then an optional name, then an optional action,
/// separated by a comma, a semicolon or a tab.
///
/// ```
/// // Ma liste
/// +41791234567
/// +41791234####,Spam Marketing
/// +41 44 123 45 67; Démarchage
/// +41221234567, Assurance, identify
/// ```
///
/// Whitespace inside a number is stripped, so numbers copied in their readable form
/// are accepted. Parsing is purely syntactic — validating that a pattern is usable
/// is the caller's job.
enum PatternImportParser {

  struct Entry: Equatable {
    let pattern: String
    let name: String?
    /// `block` or `identify` when the line states one; `nil` lets the caller decide.
    let action: String?

    init(pattern: String, name: String?, action: String? = nil) {
      self.pattern = pattern
      self.name = name
      self.action = action
    }
  }

  /// Actions a line may carry. Anything else is treated as part of the name.
  static let knownActions: Set<String> = ["block", "identify"]

  private static let separators: Set<Character> = [",", ";", "\t"]
  private static let commentPrefix = "//"

  /// Splits raw text into entries, skipping blank lines and `//` comments.
  static func parse(_ text: String) -> [Entry] {
    text.split(whereSeparator: \.isNewline).compactMap { entry(from: String($0)) }
  }

  private static func entry(from line: String) -> Entry? {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !trimmed.hasPrefix(commentPrefix) else { return nil }

    // Empty fields are kept, so a line with no name ("+4179…,,identify") still has
    // its action in third position rather than sliding into the name.
    var fields = trimmed.split(
      omittingEmptySubsequences: false,
      whereSeparator: { separators.contains($0) }
    ).map { $0.trimmingCharacters(in: .whitespaces) }
    guard !fields.isEmpty else { return nil }

    // Numbers are often pasted in readable form ("+41 79 123 45 67").
    let pattern = fields.removeFirst().filter { !$0.isWhitespace }
    guard !pattern.isEmpty else { return nil }

    // A trailing field is an action only when it actually names one. Otherwise the
    // whole remainder is the name, so a name containing a comma survives round-tripping.
    var action: String?
    if fields.count > 1, let last = fields.last,
      knownActions.contains(last.lowercased())
    {
      action = last.lowercased()
      fields.removeLast()
    }

    let name = fields.filter { !$0.isEmpty }.joined(separator: ", ")
    return Entry(pattern: pattern, name: name.isEmpty ? nil : name, action: action)
  }
}
