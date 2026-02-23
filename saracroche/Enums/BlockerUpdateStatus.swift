import Foundation
import SwiftUI

/// States of a block list update process
enum BlockerUpdateStatus: Equatable {
  case ok
  case inProgress(progress: Double)

  var description: String {
    switch self {
    case .ok:
      return "À jour"
    case .inProgress(let progress):
      return String(format: "Mise à jour en cours %.0f%%", progress)
    }
  }

  var iconName: String {
    switch self {
    case .ok:
      return "checkmark.circle.fill"
    case .inProgress:
      return "arrow.clockwise.circle.fill"
    }
  }

  var color: Color {
    switch self {
    case .ok:
      return .green
    case .inProgress:
      return .blue
    }
  }
}
