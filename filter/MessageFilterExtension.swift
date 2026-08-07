import IdentityLookup
import OSLog

private let logger = Logger(
  subsystem: "ch.swisscroche.app.filter", category: "MessageFilterExtension")

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling,
  ILMessageFilterCapabilitiesQueryHandling
{
  func handle(
    _ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest,
    context: ILMessageFilterExtensionContext,
    completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void
  ) {
    let response = ILMessageFilterCapabilitiesQueryResponse()

    // TODO: Update subActions from ILMessageFilterSubAction enum
    // response.transactionalSubActions = [...]
    // response.promotionalSubActions   = [...]

    completion(response)
  }

  /// Filtering is resolved entirely on-device against the stored patterns.
  /// Requests are never deferred to the network, so no message data leaves the device.
  func handle(
    _ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext,
    completion: @escaping (ILMessageFilterQueryResponse) -> Void
  ) {
    let (action, subAction) = self.offlineAction(for: queryRequest)

    let response = ILMessageFilterQueryResponse()
    response.action = action
    response.subAction = subAction

    completion(response)
  }

  private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> (
    ILMessageFilterAction, ILMessageFilterSubAction
  ) {
    // Without a sender there is nothing to match against, so let the message through.
    guard let sender = queryRequest.sender else {
      return (.allow, .none)
    }

    let service = MessageFilterService()
    if service.shouldFilter(sender: sender) {
      logger.info("Filtering message from sender: \(sender, privacy: .private)")
      return (.junk, .none)
    }

    return (.allow, .none)
  }
}
