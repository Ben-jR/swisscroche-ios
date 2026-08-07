import Foundation

enum ListServiceError: LocalizedError {
  case loadFailed(Error)
  case decodingFailed(Error)
  case bundledListMissing

  var errorDescription: String? {
    switch self {
    case .loadFailed(let error):
      return "Failed to load blocklist: \(error.localizedDescription)"
    case .decodingFailed(let error):
      return "Failed to decode blocklist: \(error.localizedDescription)"
    case .bundledListMissing:
      return "The bundled blocklist is missing from the app bundle."
    }
  }
}
