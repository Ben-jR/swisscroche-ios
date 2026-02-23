import SwiftUI

struct ResetCompleteSheet: View {

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        Spacer()
        VStack(spacing: 16) {
          if #available(iOS 18.0, *) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.green)
              .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2)))
          } else {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.green)
          }

          Text("Réinitialisation terminée")
            .appFont(.titleBold)
            .multilineTextAlignment(.center)
        }

        VStack(spacing: 16) {
          Text(
            "Fermer l'application manuellement pour finaliser la réinitialisation."
          )
          .appFont(.body)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.1))
        )
        Spacer()
      }
      .padding()
    }
    .interactiveDismissDisabled(true)
  }

}

#Preview {
  ResetCompleteSheet()
}
