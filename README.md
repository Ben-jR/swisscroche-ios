# Saracroche iOS

> 🤖 **Also available for Android**: [Saracroche Android](https://codeberg.org/cbouvat/saracroche-android)

## Overview

Saracroche is a privacy-focused iOS call blocking application that protects users from spam and unwanted calls using native CallKit extensions. Built with MVVM architecture and SwiftUI, it features a sophisticated pattern-based blocking system with wildcard support.

## Features

- 🛡️ **Pattern-based blocking**: Uses wildcard patterns (e.g., `33899######`) to block number ranges
- 📱 **Native CallKit extensions**: System-level call blocking and identification
- 🔒 **Privacy by design**: Zero call data collection, all processing happens on-device
- 🔄 **Automatic updates**: Background updates every 6 hours with smart reprocessing
- 📞 **Spam reporting**: Built-in reporting for unwanted calls and SMS
- 💬 **SMS filtering**: Message filtering extension for text messages

## Installation

**App Store**: 📱 [Download Saracroche](https://apps.apple.com/app/saracroche/id6743679292)

**TestFlight**: 🧪 [Try Beta Version](https://testflight.apple.com/join/CFCjF6d2)

## Enterprise Edition

Saracroche offers an **Enterprise edition** for business users with centralized management:

- 🏢 **Centralized dashboard** for managing reports and blocking data
- 📋 **Custom allow lists** for trusted business numbers
- 📊 **Centralized reporting** of unwanted calls across the organization
- 📱 **Multi-channel blocking** for calls and SMS with phishing protection
- 🔧 **MDM deployment** with zero-touch configuration
- 🔄 **Automatic updates** to keep protection current

💼 [Learn more about Saracroche for Business](https://saracroche.org/fr/business)

## For Developers

### Building from Source

```bash
# Clone repository
git clone https://github.com/Ben-jR/swisscroche-ios.git
cd swisscroche-ios

# Open in Xcode
open swisscroche.xcodeproj
```

**Requirements**:

- Xcode 15.0+
- iOS 15.0+ deployment target
- Swift 5.9+ toolchain

### Architecture

Saracroche uses a 4-target architecture:

- **Main App**: SwiftUI interface with CoreData pattern storage
- **Call Directory Extension**: CallKit-based system-level call blocking
- **Unwanted Communication Reporting**: Call/SMS spam reporting UI
- **Message Filter Extension**: SMS filtering capabilities

### Technical Stack

- **Language**: Swift 5.9+ with async/await
- **UI**: SwiftUI with MVVM architecture
- **Data**: CoreData (single "Pattern" entity)
- **iOS APIs**: CallKit, IdentityLookup, App Groups
- **Target**: iOS 15.0+, built with Xcode 15.0+

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Support

If you find Saracroche useful, consider sponsoring the project to help with maintenance and new features:

- [Sponsor and support on Saracroche.org](https://saracroche.org/fr/support)

## Star the Project ⭐

If you like Saracroche, please consider giving it a star on Codeberg to show your support and help others discover the project.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
