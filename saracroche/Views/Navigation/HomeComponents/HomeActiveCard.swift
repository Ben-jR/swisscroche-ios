import SwiftUI

struct HomeActiveCard: View {
  var totalPhoneNumbersCount: Int64
  @Binding var showInfoSheet: Bool

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "checkmark.shield.fill")
          .font(.system(size: 60))
          .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
          .foregroundColor(.green)
      } else {
        Image(systemName: "checkmark.shield.fill")
          .font(.system(size: 60))
          .foregroundColor(.green)
      }

      Text("Bloqueur actif et à jour")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      HStack(spacing: 12) {
        Image(systemName: "phone.circle.fill")
          .font(.system(size: 20))
          .frame(width: 24)
          .foregroundColor(.green)
        VStack(alignment: .leading, spacing: 2) {
          Text("Numéros dans la base de données")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)
          Text("\(totalPhoneNumbersCount.formatted())")
            .appFont(.caption)
            .foregroundColor(.secondary)
        }
        Spacer()
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel(
        Text(
          "\(totalPhoneNumbersCount.formatted()) numéros dans la base de données"
        )
      )

      Button {
        showInfoSheet = true
      } label: {
        HStack {
          Image(systemName: "info.circle.fill")
          Text("En savoir plus")
        }
      }
      .buttonStyle(
        .fullWidth(background: .green, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.green.opacity(0.15))
    )
  }
}
