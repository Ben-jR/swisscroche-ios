import AppIntents
import Foundation

/// App Intent for updating the blocker list with timeout handling
@available(iOS 16.0, *)
struct UpdateBlockerIntent: AppIntent {
  static var title: LocalizedStringResource = "Mettre à jour"
  static var description = IntentDescription("Met à jour la liste de Saracroche.")

  static var openAppWhenRun: Bool = false

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let blockerService = BlockerService()

    let completed = try await withThrowingTaskGroup(of: Bool.self) { group in
      group.addTask {
        try await blockerService.performBackgroundUpdate()
        return true
      }
      group.addTask {
        try await Task.sleep(nanoseconds: AppConstants.intentTimeoutDelay)
        return false
      }
      let result = try await group.next() ?? false
      group.cancelAll()
      return result
    }

    if completed {
      return .result(value: "Mise à jour effectuée.")
    } else {
      return .result(value: "Mise à jour partielle, veuillez relancer si nécessaire.")
    }
  }
}
