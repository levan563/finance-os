import Foundation

class TransactionStorage {
    private let key = "transactions"

    func saveTransactions(_ transactions: [Transaction]) {
        do {
            print("💾 Сохраняем транзакции в UserDefaults. Количество: \(transactions.count)")
            transactions.forEach { print("🔹 \($0.store) - \($0.amount)₽ - \( $0.date) (ID: \($0.id))") }

            let data = try JSONEncoder().encode(transactions)

            // 🔥 Полностью очищаем старые данные перед сохранением
            UserDefaults.standard.removeObject(forKey: "transactions")
            UserDefaults.standard.synchronize()  // Немедленное удаление

            // 🔥 Если массив пустой, ничего не сохраняем!
            if transactions.isEmpty {
                print("⚠️ Нет транзакций для сохранения, UserDefaults остаётся пустым.")
                return
            }

            // 🔥 Сохраняем только если массив не пуст
            UserDefaults.standard.set(data, forKey: "transactions")
            UserDefaults.standard.synchronize()

        } catch {
            print("❌ Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }




    func loadTransactions() -> [Transaction] {
        if let data = UserDefaults.standard.data(forKey: "transactions") {
            do {
                let transactions = try JSONDecoder().decode([Transaction].self, from: data)
                print("📂 Загружены транзакции: \(transactions.count)")
                transactions.forEach { print("🔹 \($0.store) - \($0.amount)₽ - \( $0.date) (ID: \($0.id))") }
                return transactions
            } catch {
                print("❌ Ошибка загрузки данных: \(error.localizedDescription)")
            }
        }
        return []
    }

}
