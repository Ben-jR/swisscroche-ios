import Foundation

enum ListServiceError: LocalizedError {
  case downloadFailed(Error)
  case decodingFailed(Error)

  var errorDescription: String? {
    switch self {
    case .downloadFailed(let error):
      return "Failed to download blocklist: \(error.localizedDescription)"
    case .decodingFailed(let error):
      return "Failed to decode blocklist: \(error.localizedDescription)"
    }
  }
}
