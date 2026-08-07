import Foundation

@MainActor
class ListsViewModel: ObservableObject {
  // MARK: - Published Properties

  // official list metadata
  @Published var officialListName: String = ""
  @Published var officialListVersion: String = ""
  @Published var officialListBlockedCount: Int = 0

  // Pattern arrays
  @Published var apiPatterns: [Pattern] = []
  @Published var userPatterns: [Pattern] = []

  // UI State
  @Published var patternError: String? = nil
  @Published var isLoading: Bool = false
  @Published var didModifyPatterns = false

  var userPatternsNumberCount: Int64 {
    userPatterns.reduce(0) { total, pattern in
      total + PhoneNumberHelpers.countPhoneNumbers(for: pattern.pattern ?? "")
    }
  }

  // MARK: - Dependencies

  private let patternService: PatternService
  private let blockerService: BlockerService

  // MARK: - Cache and helpers

  /// To store for a given calculted clocked count its String rendering
  private static var calculatedBlockedCountCache = Cache<Int64, String>()
  /// To keep only one instance of formatter without creating several for each View decreasing performances
  private static var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "fr_CH")
    return formatter
  }()

  // MARK: - Initialization

  init(
    patternService: PatternService = PatternService(),
    blockerService: BlockerService = BlockerService()
  ) {
    self.patternService = patternService
    self.blockerService = blockerService
    Task { [weak self] in
      await self?.loadData()
    }
  }

  // MARK: - Data Loading

  func loadData() async {
    await loadAPIPatterns()
    await loadUserPatterns()
    await updateOfficialListMetadata()
  }

  private func loadAPIPatterns() async {
    apiPatterns = await patternService.getPatterns(bySource: "api")
  }

  private func loadUserPatterns() async {
    userPatterns = await patternService.getPatterns(bySource: "user")
      .filter { !($0.action?.hasPrefix("remove_") ?? false) }
      .sorted { ($0.addedDate ?? Date()) > ($1.addedDate ?? Date()) }
  }

  private func updateOfficialListMetadata() async {
    if let metadata = await patternService.getOfficialListMetadata() {
      officialListName = metadata.name
      officialListVersion = Self.formatVersionDate(metadata.version)
      officialListBlockedCount = metadata.blockedCount
    }
  }

  private static func formatVersionDate(_ isoString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withFullDate]
    guard let date = isoFormatter.date(from: isoString) else { return isoString }
    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .long
    displayFormatter.timeStyle = .none
    displayFormatter.locale = Locale.current
    return displayFormatter.string(from: date)
  }

  // MARK: - Prefix CRUD Operations

  func addPattern(
    patternString: String, action: String, name: String?
  ) async {
    patternError = nil

    // Validate pattern format
    if let error = ListsViewModel.validatePatternFormat(patternString) {
      patternError = error
      return
    }

    // Strip leading '+' for storage (validation already confirmed it starts with '+')
    let storedPattern = String(patternString.dropFirst())

    // Check for duplicates across all sources (API and user)
    if let existingPattern = await patternService.getPattern(byPatternString: storedPattern) {
      if existingPattern.source == "api" {
        patternError = "Ce préfixe est déjà présent dans la liste de blocage."
      } else {
        patternError = "Ce préfixe existe déjà dans vos préfixes personnalisés."
      }
      return
    }

    // Check for overlapping ranges
    if let (overlapping, overlap) = findOverlappingPattern(storedPattern) {
      let overlappingName = overlapping.pattern ?? ""
      switch overlap {
      case .coveredByExisting:
        patternError = "Ce préfixe est déjà couvert par le préfixe existant \(overlappingName)."
      case .coversExisting:
        patternError = "Ce préfixe englobe le préfixe existant \(overlappingName)."
      }
      return
    }

    isLoading = true

    // Create pattern (stored without '+')
    if await patternService.createPattern(
      patternString: storedPattern,
      action: action,
      name: name?.isEmpty == true ? nil : name,
      source: "user"
    ) != nil {
      Logger.info("Prefix created: \(storedPattern)", category: .listsViewModel)
      // Reload data
      await loadData()
      didModifyPatterns = true
    } else {
      patternError = "Impossible de créer le préfixe."
    }

    isLoading = false
  }

  // MARK: - Import

  /// Outcome of importing a pasted or imported list.
  struct ImportSummary {
    var added = 0
    var duplicates = 0
    var overlaps = 0
    var invalid: [(pattern: String, reason: String)] = []

    var total: Int { added + duplicates + overlaps + invalid.count }
    var isEmpty: Bool { total == 0 }
  }

  /// Imports every entry of a pasted list, skipping duplicates and overlapping ranges.
  ///
  /// Unlike the manual form this accepts exact numbers without a `#` wildcard, since
  /// shared spam lists are usually made of individual numbers.
  ///
  /// The caller is responsible for setting `didModifyPatterns` once the import UI is
  /// dismissed, so the update sheet does not open on top of it.
  func importPatterns(from text: String, action: String) async -> ImportSummary {
    var summary = ImportSummary()
    let entries = PatternImportParser.parse(text)
    guard !entries.isEmpty else { return summary }

    isLoading = true
    defer { isLoading = false }

    // Patterns added during this import are not in `userPatterns` until reload,
    // so overlaps within the imported list are tracked separately.
    var addedInThisBatch: [String] = []

    for entry in entries {
      if let error = Self.validatePatternFormat(entry.pattern, requireWildcard: false) {
        summary.invalid.append((entry.pattern, error))
        continue
      }

      // Stored without the leading '+', as validation guaranteed it is there.
      let stored = String(entry.pattern.dropFirst())

      if await patternService.getPattern(byPatternString: stored) != nil {
        summary.duplicates += 1
        continue
      }

      let overlapsExisting = findOverlappingPattern(stored) != nil
      let overlapsBatch = addedInThisBatch.contains { Self.overlap(of: stored, with: $0) != nil }
      if overlapsExisting || overlapsBatch {
        summary.overlaps += 1
        continue
      }

      if await patternService.createPattern(
        patternString: stored,
        action: action,
        name: entry.name,
        source: "user"
      ) != nil {
        addedInThisBatch.append(stored)
        summary.added += 1
      } else {
        summary.invalid.append((entry.pattern, "Impossible de créer le préfixe."))
      }
    }

    if summary.added > 0 {
      Logger.info("Imported \(summary.added) patterns", category: .listsViewModel)
      await loadData()
    }

    return summary
  }

  func deletePattern(_ pattern: Pattern) async {
    await patternService.markPatternForDeletion(pattern)
    Logger.info("Prefix marked for removal: \(pattern.pattern ?? "")", category: .listsViewModel)
    await loadData()
    didModifyPatterns = true
  }

  // MARK: - Overlap Detection

  /// How a new pattern relates to an existing one when their numbers overlap.
  enum PatternOverlap {
    /// The new pattern is already covered by the existing one.
    case coveredByExisting
    /// The new pattern covers the existing one.
    case coversExisting
  }

  /// Whether two patterns cover overlapping numbers.
  /// They overlap when they have the same total length and one's fixed prefix is a
  /// prefix of the other's (since wildcards are always trailing).
  static func overlap(of new: String, with existing: String) -> PatternOverlap? {
    guard new.count == existing.count else { return nil }

    let newPrefix = new.replacingOccurrences(of: "#", with: "")
    let existingPrefix = existing.replacingOccurrences(of: "#", with: "")

    if newPrefix.hasPrefix(existingPrefix) {
      return .coveredByExisting
    }
    if existingPrefix.hasPrefix(newPrefix) {
      return .coversExisting
    }
    return nil
  }

  /// Checks if a new pattern overlaps with any already loaded pattern (bundled list or user).
  private func findOverlappingPattern(_ patternString: String) -> (
    pattern: Pattern, overlap: PatternOverlap
  )? {
    for existing in apiPatterns + userPatterns {
      guard let existingString = existing.pattern else { continue }
      if let overlap = Self.overlap(of: patternString, with: existingString) {
        return (existing, overlap)
      }
    }
    return nil
  }

  // MARK: - Display

  /// Returns the pattern string prefixed with '+' for display.
  static func displayPattern(_ pattern: String?) -> String {
    guard let pattern else { return "" }
    return "+\(pattern)"
  }

  static func calculateBlockedCount(_ pattern: Pattern) -> Int64 {
    guard let patternString = pattern.pattern else { return 0 }
    return PhoneNumberHelpers.countPhoneNumbers(for: patternString)
  }

  static func spelledOut(_ calculatedBlockCount: Int64) -> String {
    if let cachedValue = calculatedBlockedCountCache.value(forKey: calculatedBlockCount) {
      return cachedValue
    } else {
      let newValue =
        numberFormatter.string(from: NSNumber(value: calculatedBlockCount))
        ?? "\(calculatedBlockCount)"
      calculatedBlockedCountCache.setValue(newValue, forKey: calculatedBlockCount)
      return newValue
    }
  }

  // MARK: - Validation

  /// Validates a pattern string and returns an error message if invalid, or `nil` if valid.
  /// - Parameter requireWildcard: When `false`, an exact number without any `#` is accepted.
  ///   Imported lists commonly hold exact spam numbers, which the blocking engine handles fine.
  static func validatePatternFormat(_ pattern: String, requireWildcard: Bool = true) -> String? {
    let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
      return "Le préfixe ne peut pas être vide."
    }

    if trimmed.contains(" ") {
      return "Le préfixe ne doit pas contenir d'espaces."
    }

    let allowedCharacters = CharacterSet(charactersIn: "0123456789#+")
    if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
      return "Le préfixe ne peut contenir que des chiffres, « + » et « # »."
    }

    if !trimmed.hasPrefix("+") {
      return "Le préfixe doit commencer par « + » (format international)."
    }

    let hashCount = trimmed.filter { $0 == "#" }.count

    if requireWildcard, hashCount == 0 {
      return "Le préfixe doit contenir au moins un joker « # »."
    }

    if hashCount > 0, let firstHash = trimmed.firstIndex(of: "#") {
      let afterFirstHash = trimmed[firstHash...]
      if afterFirstHash.contains(where: { $0 != "#" }) {
        return "Les jokers « # » doivent être uniquement en fin de numéro."
      }
    }

    if trimmed.count < 4 {
      return "Le préfixe est trop court (minimum 4 caractères)."
    }

    if hashCount > 6 {
      return "Trop de jokers « # ». Maximum 6 jokers dans un préfixe."
    }

    return nil
  }

}
