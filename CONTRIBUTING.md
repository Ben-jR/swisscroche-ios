# Contributing to Saracroche

Thank you for considering contributing to Saracroche! We welcome contributions of all kinds, including bug fixes, feature requests, documentation improvements, and more.

## How to Contribute

### 1. Fork the Repository

- Navigate to the [Saracroche repository](https://codeberg.org/cbouvat/saracroche-ios).
- Click the "Fork" button to create your own copy of the repository.

### 2. Clone the Repository

- Clone your forked repository to your local machine:
  ```bash
  git clone https://codeberg.org/your-username/saracroche-ios.git
  cd saracroche
  ```

### 3. Create a Branch

- Create a new branch for your feature or bug fix:
  ```bash
  git checkout -b feature/your-feature-name
  ```

### 4. Make Changes

- Make your changes in the appropriate files.
- Follow the coding style and conventions used in the project.
- Ensure your changes are well-documented and tested.
- Ensure your sources are formatted:

```bash
swift-format --in-place --recursive .
# or:
make lint
```

You may need to downlaod `swift-format` before:
```bash
brew install swift-format
```

### 5. Commit Your Changes

- Commit your changes with a clear and concise commit message:
  ```bash
  git add .
  git commit -m "Add a brief description of your changes"
  ```

### 6. Push Your Changes

- Push your changes to your forked repository:
  ```bash
  git push origin feature/your-feature-name
  ```

### 7. Open a Pull Request

- Navigate to the original Saracroche repository.
- Click the "New Pull Request" button.
- Select your branch and provide a detailed description of your changes.

## Building the app

### Apply your own configuration

You may notice the project may not compile on your device, because you need to change your local Apple configuration.

1. Define in your Apple account a new App ID and a new App Group to
2. In the targets and projects settings (*saracroche.xcodeproj/project.pbxproj*), use your own Apple team and apply the freshly crated App ID and App Group
3. Use the suitable App ID and App Group in the *entitlements* files
4. Change the App ID and App Group defined in the source code (*AppConstants*, *NotificationService*, *Logger*, *CallDirectoryHandler*, *MessageFilterExtension*, *MessageFilterService* )

If you do not follow these steps, project may not compile or app may crash at start during storage initialization.

### Manage Git branches

Here are some tips how how to submit contributions without pollution to upstream:

1. Make a fork
2. Clone your fork
3. Add the origin repository as remote (say upstream)
4. Synchronize upstream *main* branch in yours
5. Create your work branch from your *main* branch
6. Implement your evolutions with clear commits
7. Create another branch but from *upstream main* branch
8. Cherry-pick your commits and push.
9. Create the pull request from this branch which will contain only the evolutions and not your configurations changes (in most of cases)

## Code of Conduct

Please note that this project is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms.

## Reporting Issues

If you encounter a bug or have a feature request, please open an issue in the [Codeberg Issues](https://codeberg.org/cbouvat/saracroche-ios/issues) section. Provide as much detail as possible to help us address the issue.

## Development Environment

### Prerequisites

- Xcode (latest version)
- macOS

### Building the Project

1. Open `saracroche.xcodeproj` in Xcode.
2. Select your target device or simulator.
3. Build and run the project.

## License

By contributing to Saracroche, you agree that your contributions will be licensed under the [GNU General Public License v3.0](LICENSE).
