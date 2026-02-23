import Foundation

enum CallDirectoryError: LocalizedError {
  case statusCheckFailed(Error)
  case settingsOpenFailed(Error)
  case reloadFailed(Error)

  var errorDescription: String? {
    switch self {
    case .statusCheckFailed(let error):
      return "Failed to check extension status: \(error.localizedDescription)"
    case .settingsOpenFailed(let error):
      return "Failed to open settings: \(error.localizedDescription)"
    case .reloadFailed(let error):
      return "Failed to reload extension: \(error.localizedDescription)"
    }
  }
}
