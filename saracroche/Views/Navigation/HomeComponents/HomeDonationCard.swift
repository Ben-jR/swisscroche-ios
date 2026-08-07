import SwiftUI

struct HomeDonationCard: View {
  @ObservedObject var userPreferences: UserPreferencesViewModel
  @Binding var showDonationSheet: Bool

  var body: some View {
    if !userPreferences.isDonationDismissed {
      VStack(alignment: .leading, spacing: 0) {
        Text("Soutenez SwissCroche")
          .appFont(.headlineSemiBold)
          .padding(.horizontal, 16)
          .padding(.top, 16)
          .padding(.bottom, 4)

        Text(
          "SwissCroche est une application entièrement gratuite, open source et sans publicité. "
            + "Elle vit grâce aux dons de toutes les personnes qui l'utilisent pour continuer à évoluer."
        )
        .appFont(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)

        Button {
          showDonationSheet = true
        } label: {
          HStack {
            Image(systemName: "heart.fill")
              .foregroundColor(.white)
            Text("Soutenez")
          }
        }
        .buttonStyle(
          .fullWidth(background: Color.pink, foreground: .white)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.1))
      )
    }
  }
}
