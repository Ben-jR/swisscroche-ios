import Foundation
import SwiftUI

/// View model for phone number reporting
@MainActor
class ReportViewModel: ObservableObject {
  @Published var phoneNumber: String = ""
  @Published var isGood: Bool = false  // false = spam, true = legitimate
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  @Published var alertType: AlertType = .info

  enum AlertType {
    case success
    case error
    case info

    var title: String {
      switch self {
      case .success: return "Succès"
      case .error: return "Erreur"
      case .info: return "Information"
      }
    }
  }

  private let apiService = ReportAPIService()

  func submitPhoneNumber() async {
    // Format the phone number before validation
    phoneNumber = formatPhoneNumber(phoneNumber)

    guard validatePhoneNumber() else { return }

    do {
      try await apiService.report(phoneNumber, isGood: isGood)
      handleSuccess()
    } catch {
      handleError(error)
    }
  }

  private func validatePhoneNumber() -> Bool {
    let trimmedNumber = phoneNumber.trimmingCharacters(
      in: .whitespacesAndNewlines
    )

    if trimmedNumber.isEmpty {
      showError("Veuillez entrer un numéro de téléphone")
      return false
    }

    // Clean: keep + at the beginning if present, then digits only
    let cleaned: String
    if trimmedNumber.hasPrefix("+") {
      let remaining = String(trimmedNumber.dropFirst())
      let digits = remaining.filter { $0.isNumber }
      cleaned = "+" + digits
    } else {
      cleaned = trimmedNumber.filter { $0.isNumber }
    }

    // Extract digits only (without +) for validation
    let digitsOnly = cleaned.replacingOccurrences(of: "+", with: "")

    // Validate: must contain at least 2 digits and at most 15 digits
    if digitsOnly.count < 2 {
      showError("Le numéro doit contenir au moins 2 chiffres")
      return false
    }
    if digitsOnly.count > 15 {
      showError("Le numéro doit contenir au maximum 15 chiffres")
      return false
    }

    // Update with the cleaned version
    phoneNumber = cleaned

    return true
  }

  private func handleSuccess() {
    phoneNumber = ""
    alertType = .success
    let message =
      isGood
      ? "Numéro de téléphone signalé comme légitime. Merci pour votre contribution !"
      : "Numéro de téléphone signalé comme spam. Merci pour votre contribution !"
    alertMessage = message
    showAlert = true
  }

  private func handleError(_ error: Error) {
    if let networkError = error as? NetworkError {
      alertType = .error
      alertMessage = networkError.userMessage
    } else {
      alertType = .error
      alertMessage = "Une erreur inattendue s'est produite. Veuillez réessayer."
    }
    showAlert = true
  }

  private func showError(_ message: String) {
    alertType = .error
    alertMessage = message
    showAlert = true
  }

  func formatPhoneNumber(_ input: String) -> String {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("+") {
      let remaining = String(trimmed.dropFirst())
      let digits = remaining.filter { $0.isNumber }
      return "+" + digits
    }
    return trimmed.filter { $0.isNumber }
  }

}

// Extension for String to match regex
extension String {
  fileprivate func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression) != nil
  }
}
