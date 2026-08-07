import Foundation

enum CoreDataError: LocalizedError {
  /// No persistent store loaded — typically the App Group container is unreachable,
  /// which means the app's signing configuration is wrong.
  case storeUnavailable

  var errorDescription: String? {
    switch self {
    case .storeUnavailable:
      return
        "La base de données n'est pas accessible. Vérifiez la configuration du groupe d'applications."
    }
  }
}
