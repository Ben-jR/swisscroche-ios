import Foundation

enum BlockerServiceError: LocalizedError {
  case listUpdateFailed(Error)
  case extensionReloadFailed(Error)
  var errorDescription: String? {
    switch self {
    case .listUpdateFailed(let error):
      return "List update failed: \(error.localizedDescription)"
    case .extensionReloadFailed(let error):
      return "Extension reload failed: \(error.localizedDescription)"
    }
  }
}
