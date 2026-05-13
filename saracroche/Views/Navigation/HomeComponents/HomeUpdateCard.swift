import SwiftUI

struct HomeUpdateCard: View {
  @Binding var showUpdateInProgressSheet: Bool

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .rotate.byLayer,
            options: .repeat(.periodic(delay: 2.0))
          )
          .foregroundColor(.blue)
      } else {
        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
      }

      Text("Mise à jour disponible")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      Text("Une mise à jour de la liste est disponible.")
        .appFont(.body)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        showUpdateInProgressSheet = true
      } label: {
        HStack {
          Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
          Text("Mettez à jour la liste")
        }
      }
      .buttonStyle(
        .fullWidth(background: .blue, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.15))
    )
  }
}
