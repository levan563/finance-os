import SwiftUI

struct ContentView: View {
    @State private var transactions: [Transaction] = []
    @State private var filteredTransactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?
    @State private var isEditing = false
    @State private var isAddingTransaction = false
    @State private var isShowingCategories = false
    
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var currentYear = Calendar.current.component(.year, from: Date())

    var totalIncome: Double {
        filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: previousMonth) { Image(systemName: "chevron.left") }
                    Text("\(monthName(currentMonth)) \(String(currentYear))")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    Button(action: nextMonth) { Image(systemName: "chevron.right") }
                }
                .padding()

                VStack {
                    HStack {
                        VStack {
                            Text("Доходы")
                                .font(.headline)
                            Text("\(totalIncome, specifier: "%.2f") ₽")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            Text("Расходы")
                                .font(.headline)
                            Text("\(totalExpense, specifier: "%.2f") ₽")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                ScrollView {
                    LazyVStack {
                        ForEach(filteredTransactions.indices, id: \.self) { index in
                            let transaction = filteredTransactions[index]

                            Button(action: {
                                selectedTransaction = transaction
                                isEditing = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.store)
                                            .font(.headline)
                                        Text("\(transaction.amount, specifier: "%.2f") ₽")
                                            .font(.subheadline)
                                            .foregroundColor(transaction.type == .income ? .green : .red)
                                        Text(transaction.date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        if let category = transaction.category {
                                            Text("Категория: \(category.name)")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Spacer()
                                    Text(transaction.type.rawValue)
                                        .font(.caption)
                                        .padding(6)
                                        .background(transaction.type == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                        .foregroundColor(transaction.type == .income ? .green : .red)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .onDelete(perform: deleteTransaction)
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 400)
                ZStack {
                    // 🔥 КНОПКИ В ПРАВОМ НИЖНЕМ УГЛУ
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 20) { // ✅ Размещаем кнопки вертикально
                                // 🔥 Кнопка "Категории"
                                NavigationLink(destination: CategoriesView()) {
                                    Image(systemName: "folder.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .padding()
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }

                                // 🔥 Кнопка "Добавить транзакцию"
                                Button(action: { isAddingTransaction = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .padding()
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }
                            }
                            .padding(.trailing, 20) // ✅ Двигаем кнопки вплотную к правому краю
                        }
                        .padding(.bottom, 20) // ✅ Двигаем кнопки вниз
                    }

                }
                .sheet(isPresented: $isAddingTransaction) {
                    AddTransactionView(onSave: saveTransaction)
                }

                
                
            }
            .sheet(isPresented: $isAddingTransaction) {
                AddTransactionView(onSave: saveTransaction)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction, transactions: $transactions, reloadTransactions: reloadTransactions)
            }
            .onAppear {
                reloadTransactions()
            }
        }
    }
    func extractMonth(from dateString: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return Calendar.current.component(.month, from: date)
        }
        return 0
    }

    func extractYear(from dateString: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return Calendar.current.component(.year, from: date)
        }
        return 0
    }


    func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        reloadTransactions()
    }

    func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        reloadTransactions()
    }

    func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[month - 1].capitalized
    }

    func reloadTransactions() {
        DispatchQueue.main.async {
            print("🔄 Перезагружаем транзакции...")

            let loadedTransactions = TransactionStorage().loadTransactions()
            transactions = loadedTransactions

            print("📂 Загружены транзакции: \(transactions.count)")
            transactions.forEach { print("🔹 \($0.store) - \($0.amount)₽ - \($0.date)") }

            let monthFiltered = transactions.filter { extractMonth(from: $0.date) == currentMonth }
            filteredTransactions = monthFiltered.filter { extractYear(from: $0.date) == currentYear }

            print("✅ Загружено после фильтрации: \(filteredTransactions.count) транзакций")
            filteredTransactions.forEach { print("🔹 \($0.store) - \($0.amount)₽ - \($0.date)") }
        }
    }



    func saveTransactions(_ transactions: [Transaction]) {
        do {
            print("💾 Сохраняем транзакции в UserDefaults. Количество: \(transactions.count)")
            transactions.forEach { print("🔹 \($0.store) - \($0.amount)₽ - \($0.date)") }

            let data = try JSONEncoder().encode(transactions)

            // 🔥 Полностью очищаем старые данные перед сохранением
            UserDefaults.standard.removeObject(forKey: "transactions")
            UserDefaults.standard.set(data, forKey: "transactions")
            UserDefaults.standard.synchronize() // Гарантируем немедленное сохранение

        } catch {
            print("❌ Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }

    func saveTransaction(_ transaction: Transaction) {
        print("✏️ Сохранение транзакции: \(transaction.store) - \(transaction.amount)₽ - \(transaction.date)")

        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            print("🔄 Обновляем существующую транзакцию")
            transactions[index] = transaction
        } else {
            print("➕ Добавляем новую транзакцию")
            transactions.append(transaction)
        }

        TransactionStorage().saveTransactions(transactions) // Теперь сохраняем только через этот метод

        reloadTransactions()
    }




    func deleteTransaction(at offsets: IndexSet) {
        print("🚨 deleteTransaction() вызван!")

        offsets.forEach { index in
            let transactionToDelete = filteredTransactions[index]
            print("🗑 Попытка удалить: \(transactionToDelete.store) - \(transactionToDelete.date) (ID: \(transactionToDelete.id))")

            transactions = transactions.filter { $0.id != transactionToDelete.id }
            filteredTransactions = filteredTransactions.filter { $0.id != transactionToDelete.id }
        }

        print("💾 Данные перед сохранением (после удаления): \(transactions.count)")
        transactions.forEach { print("🔹 \($0.store) - \($0.date) (ID: \($0.id))") }

        TransactionStorage().saveTransactions(transactions)

        reloadTransactions()
    }
}
