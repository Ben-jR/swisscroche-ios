import Foundation

@MainActor
class ListsViewModel: ObservableObject {
  // MARK: - Published Properties

  // French list metadata
  @Published var frenchListName: String = ""
  @Published var frenchListVersion: String = ""
  @Published var frenchListBlockedCount: Int = 0

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
    await updateFrenchListMetadata()
  }

  private func loadAPIPatterns() async {
    apiPatterns = await patternService.getPatterns(bySource: "api")
  }

  private func loadUserPatterns() async {
    userPatterns = await patternService.getPatterns(bySource: "user")
      .filter { !($0.action?.hasPrefix("remove_") ?? false) }
      .sorted { ($0.addedDate ?? Date()) > ($1.addedDate ?? Date()) }
  }

  private func updateFrenchListMetadata() async {
    if let metadata = await patternService.getFrenchListMetadata() {
      frenchListName = metadata.name
      frenchListVersion = Self.formatVersionDate(metadata.version)
      frenchListBlockedCount = metadata.blockedCount
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
    if let (overlapping, newIsSubset) = findOverlappingPattern(storedPattern) {
      let overlappingName = overlapping.pattern ?? ""
      if newIsSubset {
        patternError = "Ce préfixe est déjà couvert par le préfixe existant \(overlappingName)."
      } else {
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

  func deletePattern(_ pattern: Pattern) async {
    await patternService.markPatternForDeletion(pattern)
    Logger.info("Prefix marked for removal: \(pattern.pattern ?? "")", category: .listsViewModel)
    await loadData()
    didModifyPatterns = true
  }

  // MARK: - Overlap Detection

  /// Checks if a new pattern overlaps with any existing pattern (API or user).
  /// Two patterns overlap when they have the same total length and one's fixed prefix
  /// is a prefix of the other's (since wildcards are always trailing).
  private func findOverlappingPattern(_ patternString: String) -> (pattern: Pattern, newIsSubset: Bool)? {
    let newPrefix = patternString.replacingOccurrences(of: "#", with: "")
    let newLength = patternString.count

    let allPatterns = apiPatterns + userPatterns
    for existing in allPatterns {
      guard let existingString = existing.pattern else { continue }
      let existingPrefix = existingString.replacingOccurrences(of: "#", with: "")
      let existingLength = existingString.count

      guard newLength == existingLength else { continue }

      if newPrefix.hasPrefix(existingPrefix) {
        return (existing, newIsSubset: true)
      }
      if existingPrefix.hasPrefix(newPrefix) {
        return (existing, newIsSubset: false)
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

  // MARK: - Validation

  /// Validates a pattern string and returns an error message if invalid, or `nil` if valid.
  static func validatePatternFormat(_ pattern: String) -> String? {
    let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
      return "Le préfixe ne peut pas être vide."
    }

    if trimmed.contains(" ") {
      return "Le préfixe ne doit pas contenir d'espaces."
    }

    let allowedCharacters = CharacterSet(charactersIn: "0123456789#+")
    if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
      return "Le préfixe ne peut contenir que des chiffres, '+' et '#'."
    }

    if !trimmed.hasPrefix("+") {
      return "Le préfixe doit commencer par '+' (format international)."
    }

    let hashCount = trimmed.filter { $0 == "#" }.count

    if hashCount == 0 {
      return "Le préfixe doit contenir au moins un joker '#'."
    }

    if hashCount > 0, let firstHash = trimmed.firstIndex(of: "#") {
      let afterFirstHash = trimmed[firstHash...]
      if afterFirstHash.contains(where: { $0 != "#" }) {
        return "Les jokers '#' doivent être uniquement en fin de numéro."
      }
    }

    if trimmed.count < 4 {
      return "Le préfixe est trop court (minimum 4 caractères)."
    }

    if hashCount > 6 {
      return "Trop de jokers '#'. Maximum 6 jokers dans un préfixe."
    }

    return nil
  }

}
