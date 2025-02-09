import AppIntents

@available(iOS 16.0, *)
struct MyAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTransactionIntent(),
            phrases: ["Добавить транзакцию в \(.applicationName)"],
            shortTitle: "Добавить транзакцию",
            systemImageName: "plus.circle"
        )
    }
}
