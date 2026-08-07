import AppIntents

@available(iOS 16.0, *)
struct SwissCrocheShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: UpdateBlockerIntent(),
      phrases: [
        "Mettre à jour \(.applicationName)",
        "Actualiser \(.applicationName)",
      ],
      shortTitle: "Mettre à jour",
      systemImageName: "arrow.clockwise.circle.fill"
    )
  }
}
