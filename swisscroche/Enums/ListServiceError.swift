import Foundation

enum ListServiceError: LocalizedError {
  case loadFailed(Error)
  case decodingFailed(Error)
  case bundledListMissing
  case invalidRemoteURL
  case remoteUnavailable
  case remoteListInvalid

  var errorDescription: String? {
    switch self {
    case .loadFailed(let error):
      return "Failed to load blocklist: \(error.localizedDescription)"
    case .decodingFailed(let error):
      return "Failed to decode blocklist: \(error.localizedDescription)"
    case .bundledListMissing:
      return "The bundled blocklist is missing from the app bundle."
    case .invalidRemoteURL:
      return "The remote blocklist URL is malformed."
    case .remoteUnavailable:
      return "The remote blocklist could not be reached."
    case .remoteListInvalid:
      return "The remote blocklist is empty or malformed."
    }
  }
}
