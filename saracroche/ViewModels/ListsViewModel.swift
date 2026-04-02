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

    // Check for duplicates across all sources (API and user)
    if let existingPattern = await patternService.getPattern(byPatternString: patternString) {
      if existingPattern.source == "api" {
        patternError = "Ce préfixe est déjà présent dans la liste de blocage."
      } else {
        patternError = "Ce préfixe existe déjà dans vos préfixes personnalisés."
      }
      return
    }

    isLoading = true

    // Create pattern
    if await patternService.createPattern(
      patternString: patternString,
      action: action,
      name: name?.isEmpty == true ? nil : name,
      source: "user"
    ) != nil {
      Logger.info("Prefix created: \(patternString)", category: .listsViewModel)
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
