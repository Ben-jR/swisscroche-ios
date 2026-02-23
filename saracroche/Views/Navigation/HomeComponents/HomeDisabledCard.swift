import SwiftUI

struct HomeDisabledCard: View {
  @ObservedObject var blockerStatus: BlockerStatusViewModel

  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      if blockerStatus.blockerExtensionStatus == .disabled {
        disabledStatusView
      } else if blockerStatus.blockerExtensionStatus == .unknown {
        unknownStatusView
      } else if blockerStatus.blockerExtensionStatus == .error {
        errorStatusView
      } else if blockerStatus.blockerExtensionStatus == .unexpected {
        unexpectedStatusView
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .center)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.red.opacity(0.15))
    )
  }

  private var disabledStatusView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .pulse.byLayer,
            options: .repeat(.periodic(delay: 2.0))
          )
          .foregroundColor(.red)
      } else {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.red)
      }

      Text("Le bloqueur n'est pas activé")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      setupStepsView

      Button {
        Task {
          await blockerStatus.openSettings()
        }
      } label: {
        HStack {
          Image(systemName: "gear")
          Text("Activez dans les réglages de l'iPhone")
        }
      }
      .buttonStyle(
        .fullWidth(background: Color.red, foreground: .white)
      )
    }
  }

  private var setupStepsView: some View {
    VStack(spacing: 12) {
      HStack(spacing: 12) {
        Image(systemName: "gearshape.fill")
          .font(.system(size: 20))
          .foregroundColor(.red)
          .frame(width: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text("Étape 1 : Ouvrir les réglages")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)

          Text("Cliquez sur le bouton ci-dessous pour accéder aux réglages iPhone.")
            .appFont(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()
      }

      HStack(spacing: 12) {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 20))
          .foregroundColor(.red)
          .frame(width: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text("Étape 2 : Activez Saracroche")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)

          Text(
            "Activez Saracroche dans la liste des apps de blocage d'appels et identification."
          )
          .appFont(.caption)
          .foregroundColor(.secondary)
        }

        Spacer()
      }

      HStack(spacing: 12) {
        Image(systemName: "arrow.down.circle.fill")
          .font(.system(size: 20))
          .foregroundColor(.red)
          .frame(width: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text("Étape 3 : Installer la liste")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)

          Text("Revenez dans l'app pour installer la liste de blocage")
            .appFont(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()
      }
    }
  }

  private var unknownStatusView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "questionmark.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.orange)
      } else {
        Image(systemName: "questionmark.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.orange)
      }

      Text("Vérification du bloqueur en cours")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      Text(
        "Patientez pendant la vérification de l'app de blocage d'appels."
      )
      .appFont(.body)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var errorStatusView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "xmark.octagon.fill")
          .font(.system(size: 60))
          .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.red)
      } else {
        Image(systemName: "xmark.octagon.fill")
          .font(.system(size: 60))
          .foregroundColor(.red)
      }

      Text("Erreur lors de la vérification")
        .appFont(.title3Bold)

      Text(
        "Fermez l'application et relancez-la."
      )
      .appFont(.body)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var unexpectedStatusView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .wiggle.up.byLayer,
            options: .repeat(.periodic(delay: 2.5))
          )
          .foregroundColor(.orange)
      } else {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .foregroundColor(.orange)
      }

      Text("Statut inattendu")
        .appFont(.title3Bold)
        .multilineTextAlignment(.center)

      Text(
        "Fermez l'application et relancez-la."
      )
      .appFont(.body)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
