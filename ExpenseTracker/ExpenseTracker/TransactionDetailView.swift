import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var transaction: Transaction
    @Binding var transactions: [Transaction]
    var reloadTransactions: () -> Void

    var body: some View {
        NavigationView {
            Form {
                // ✅ Переместили выбор типа в начало
                Section(header: Text("Тип")) {
                    Picker("Тип", selection: $transaction.type) {
                        Text("Расход").tag(TransactionType.expense)
                        Text("Доход").tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Название")) {
                    TextField("Название", text: $transaction.store)
                }

                Section(header: Text("Сумма")) {
                    TextField("Сумма", value: $transaction.amount, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Дата")) {
                    DatePicker("", selection: Binding(
                        get: { dateFormatter().date(from: transaction.date) ?? Date() },
                        set: { transaction.date = dateFormatter().string(from: $0) }
                    ), displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle()) // ✅ Оставили развернутый календарь
                }

                // 🔥 КНОПКА УДАЛЕНИЯ ВНИЗУ
                Section {
                    Button(action: deleteTransaction) {
                        Text("Удалить транзакцию")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Редактирование")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTransaction()
                    }
                }
            }
        }
    }

    func saveTransaction() {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        } else {
            transactions.append(transaction)
        }

        TransactionStorage().saveTransactions(transactions)
        reloadTransactions()
        presentationMode.wrappedValue.dismiss()
    }

    func deleteTransaction() {
        print("🗑 Удаление транзакции: \(transaction.store) - \(transaction.date) (ID: \(transaction.id))")

        // Удаляем транзакцию из списка
        transactions.removeAll { $0.id == transaction.id }
        TransactionStorage().saveTransactions(transactions)

        // 🔄 Обновляем список транзакций на главном экране
        reloadTransactions()

        // Закрываем окно редактирования
        presentationMode.wrappedValue.dismiss()
    }

    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
