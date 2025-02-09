import AppIntents

struct AddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Добавить транзакцию"
    
    @Parameter(title: "Название")
    var store: String

    @Parameter(title: "Сумма")
    var amount: Double

    @Parameter(title: "Дата", default: Date.now)
    var date: Date

    func perform() async throws -> some IntentResult {
        print("🟢 Добавление новой транзакции через Siri Shortcuts")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        // 🔥 Теперь создаём транзакцию строго по конструктору в `Transaction.swift`
        let newTransaction = Transaction(
            amount: amount,
            store: store,
            date: dateString,
            category: nil,
            type: .expense // Все транзакции через Siri идут как расход
        )

        print("✅ Создана транзакция: \(newTransaction.store) - \(newTransaction.amount)₽ - \(newTransaction.date)")

        var transactions = TransactionStorage().loadTransactions()
        transactions.append(newTransaction)

        TransactionStorage().saveTransactions(transactions)

        print("💾 Сохранена транзакция через Siri: \(newTransaction.store) - \(newTransaction.amount)₽ - \(newTransaction.date)")
        
        return .result()
    }
}
