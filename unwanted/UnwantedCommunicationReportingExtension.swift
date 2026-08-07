import Combine
import IdentityLookup
import IdentityLookupUI
import SwiftUI

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController {
  private let viewModel = UnwantedReportViewModel()
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwiftUIView()

    // Observe selectedAction to update isReadyForClassificationResponse
    viewModel.$selectedAction
      .sink { [weak self] action in
        self?.extensionContext.isReadyForClassificationResponse = action != nil
      }
      .store(in: &cancellables)
  }

  private func setupSwiftUIView() {
    let swiftUIView = UnwantedCommunicationReportingView(viewModel: viewModel)
    let hostingController = UIHostingController(rootView: swiftUIView)

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  // Customize UI based on the classification request before the view is loaded
  override func prepare(for classificationRequest: ILClassificationRequest) {
    switch classificationRequest {
    case let classificationRequest as ILMessageClassificationRequest:
      viewModel.phone = classificationRequest.messageCommunications.first?.sender ?? ""
    case let classificationRequest as ILCallClassificationRequest:
      viewModel.phone = classificationRequest.callCommunications.first?.sender ?? ""
    default:
      viewModel.phone = ""
    }
  }

  // Provide a classification response for the classification request
  override func classificationResponse(for request: ILClassificationRequest)
    -> ILClassificationResponse
  {
    guard let action = viewModel.selectedAction else {
      return ILClassificationResponse(action: .none)
    }

    let response = ILClassificationResponse(action: action)
    let phone = extractPhoneNumber(from: request)

    // Get device ID
    let deviceId = getOrCreateDeviceID()

    // Determine if the number is good (legitimate) or spam
    let isGood: Bool
    switch action {
    case .reportNotJunk:
      isGood = true  // Legitimate number
    case .reportJunk, .reportJunkAndBlockSender:
      isGood = false  // Spam number
    case .none:
      isGood = false
    @unknown default:
      isGood = false  // Default to spam for unknown actions
    }

    // Create userInfo with phone, device ID, is good flag, and country code
    // iOS will automatically nest these into the classification object
    response.userInfo = [
      "phone": phone,
      "device_id": deviceId,
      "is_good": isGood,
      "country_code": "CH",
    ]

    return response
  }

  // MARK: - Helper Methods

  private func getOrCreateDeviceID() -> String {
    // Key for storing device ID in UserDefaults
    let deviceIDKey = "extensionDeviceID"

    // Try to get UserDefaults
    let userDefaults = UserDefaults.standard

    // Check if we already have a device ID
    if let existingDeviceID = userDefaults.string(forKey: deviceIDKey) {
      return existingDeviceID
    }

    // Generate a new UUID for this extension
    let newDeviceID = UUID().uuidString

    // Store the device ID in UserDefaults
    userDefaults.set(newDeviceID, forKey: deviceIDKey)

    return newDeviceID
  }

  // MARK: - Helper Methods

  private func extractPhoneNumber(from request: ILClassificationRequest) -> String {
    switch request {
    case let request as ILMessageClassificationRequest:
      return request.messageCommunications.first?.sender ?? ""
    case let request as ILCallClassificationRequest:
      return request.callCommunications.first?.sender ?? ""
    default:
      return ""
    }
  }
}
