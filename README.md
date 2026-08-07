# SwissCroche iOS

> **A fork of [Saracroche](https://codeberg.org/cbouvat/saracroche-ios)**, adapted for Switzerland.
> Not affiliated with, endorsed by, or supported by the original project or its author.
> All credit for the original work goes to [cbouvat](https://codeberg.org/cbouvat).

## Status

⚠️ **Work in progress — not released.** This app is not on the App Store or TestFlight, and building it
requires your own Apple Developer account (see [Building from source](#building-from-source)).
Read [Known limitations](#known-limitations) before using it for anything real.

## Overview

SwissCroche blocks unwanted calls on iOS using Apple's native CallKit extensions. Blocking rules are
wildcard number patterns (e.g. `41900######` blocks every number starting with +41 900), applied
entirely on-device — no call data leaves your phone for the blocking itself.

## Features

- 🛡️ **Pattern-based blocking** — wildcard patterns cover whole number ranges
- 📱 **Native CallKit extensions** — system-level call blocking and identification
- 🔒 **Fully on-device** — the block list is bundled in the app; nothing about your calls or
  messages is sent anywhere
- 💬 **SMS filtering** — message filter extension checks senders against the same patterns
- ✏️ **Custom patterns** — add your own prefixes to block on top of the bundled list

## What's different from upstream

| | Saracroche (upstream) | SwissCroche |
|---|---|---|
| Block list | French ARCEP operator list, downloaded from `app.saracroche.org` | Swiss BAKOM/OFCOM premium-rate prefixes, **bundled in the app** |
| Blocked prefixes | French ranges | `+41 900` (services), `+41 901` (contests/voting), `+41 906` (adult) |
| Spam reporting | Reports sent to `app.saracroche.org` | **Removed** — no backend of our own to send to |
| Targets | 4 (app, blocker, filter, unwanted) | 3 (app, blocker, filter) |
| Number examples in UI | `+33…` | `+41…` |
| Number spelling | `fr_FR` (soixante-dix, quatre-vingt-dix) | `fr_CH` (septante, nonante) |
| Bundle ID / App Group | `com.cbouvat.saracroche` | `ch.swisscroche.app` |

Upstream's donation links, App Store review link, support/help/website links, and Enterprise offering
were removed rather than rebranded — they belong to the original author and would be misleading under a
different app identity.

## Known limitations

Be aware of these before relying on the app:

- **This is not a spam database.** The bundled list only covers Switzerland's official premium-rate
  ranges (090x). It does *not* block reported spam numbers, scam callers, or spoofed numbers. Real
  anti-spam coverage would need a data source we don't currently have.
- **There is no spam reporting.** It was removed rather than left pointing at upstream's server.
  Adding it back requires a backend of our own.
- **The list no longer updates over the network.** Background refresh still re-applies patterns to
  CallKit, but the list itself only changes when the app is updated.
- **Enterprise/MDM code still targets upstream.** The inherited business features (organization API
  key, health check, the hidden debug menu's list download) still point at `app.saracroche.org`.
  They are dormant without an MDM-provisioned API key, but the code is still there.
- **French UI only.** No German, Italian, or Romansh — a real Swiss app should be localized. There is
  currently no localization infrastructure at all (strings are hardcoded in the views).
- **Wangiri / call spoofing are not addressed.** Blocking by foreign country code would also block
  legitimate calls, so it isn't done automatically. Since January 2026 Swiss operators are required to
  flag or block spoofed numbers at network level.

## Building from source

```bash
git clone https://github.com/Ben-jR/swisscroche-ios.git
cd swisscroche-ios
open swisscroche.xcodeproj
```

**Requirements**: Xcode 15.0+, iOS 15.0+ deployment target, Swift 5.9+.

### Code signing

The app and its extensions share data through an App Group, so **running on a device or simulator
requires your own Apple Developer team**:

1. Create an App ID and an App Group in your Apple Developer account.
2. Set your team and the new identifiers in the target settings and in the `*.entitlements` files.
3. Update `AppConstants.appGroupIdentifier` and the related IDs in `shared/AppConstants.swift`.

To only check that it compiles, you can skip signing:

```bash
xcodebuild -project swisscroche.xcodeproj -scheme swisscroche -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Note that an unsigned build has no App Group access, so the app crashes on launch when CoreData
initializes — it is only useful for verifying compilation.

### Commands

```bash
make lint    # Format Swift code with swift-format (required after changes)
make build   # Build the project
make test    # Run unit tests on a simulator
```

## Architecture

Three targets sharing data through the `group.ch.swisscroche.app` App Group:

- **swisscroche** — main app: SwiftUI + MVVM, CoreData pattern storage, orchestrates updates
- **blocker** — Call Directory extension: applies block/identify actions to the CallKit directory
- **filter** — Message Filter extension: checks incoming SMS senders against stored patterns

Plus `shared/`, compiled into the app and the `blocker`/`filter` extensions, and `swisscrocheTests/`.

**Technical stack**: Swift 5.9+ with async/await, SwiftUI (MVVM), CoreData (single `Pattern` entity),
CallKit / IdentityLookup / App Groups.

See [AGENTS.md](AGENTS.md) for the inter-process data flow and project conventions.

## Contributing

Issues and pull requests are welcome on
[this fork](https://github.com/Ben-jR/swisscroche-ios). See [CONTRIBUTING.md](CONTRIBUTING.md).

Improvements that aren't Switzerland-specific are better sent
[upstream](https://codeberg.org/cbouvat/saracroche-ios) so everyone benefits.

To pull in upstream changes:

```bash
git fetch upstream
git merge upstream/main
```

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

This is a derivative work of Saracroche by cbouvat, used under the terms of the GPLv3. If you
distribute a build of this app, the GPLv3 requires you to make your source code available to its
users.
