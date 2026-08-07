import SwiftUI

struct HomeLoadingCard: View {
  var loadingStep: String

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .rotate.clockwise.byLayer,
            options: .repeat(.periodic(delay: 1.0))
          )
          .foregroundColor(.gray)
      } else {
        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.gray)
      }

      Text("Chargement en cours")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      Text(loadingStep)
        .appFont(.body)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .center)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.15))
    )
  }
}
