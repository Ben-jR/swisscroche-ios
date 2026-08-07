# Security Policy

## Reporting a vulnerability

Report vulnerabilities in **SwissCroche** privately through GitHub:
[open a security advisory](https://github.com/Ben-jR/swisscroche-ios/security/advisories/new).
Please do not open a public issue for a security problem.

This is a fork and is maintained separately. Do not send reports about this fork
to the upstream [Saracroche](https://codeberg.org/cbouvat/saracroche-ios)
project — and if you find a vulnerability that also affects upstream, please
report it to them directly as well.

## Scope

The app runs entirely on-device and makes no network requests other than
fetching its public block list. It stores no personal data off-device and has no
accounts, so the realistic attack surface is:

- The bundled and remotely fetched block list (`SwissList.json`) — a malformed or
  tampered list could disrupt call blocking
- The App Group container shared between the app and its CallKit / message filter
  extensions
