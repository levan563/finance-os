import SwiftUI

struct AddTransactionView: View {
    @State private var amount: String = ""
    @State private var store: String = ""
    @State private var selectedDate = Date()  // Используем `Date` вместо `String`
    @State private var selectedCategory: Category? = nil
    @State private var selectedType: TransactionType = .expense
    @State private var categories: [Category] = CategoryStorage().loadCategories()
    var onSave: (Transaction) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали транзакции")) {
                    TextField("Магазин", text: $store)
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    // Календарь для выбора даты
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle()) // Стиль календаря
                }

                Section(header: Text("Тип транзакции")) {
                    Picker("Тип", selection: $selectedType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Категория")) {
                    Picker("Категория", selection: $selectedCategory) {
                        Text("Без категории").tag(Category?.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Category?.some(category))
                        }
                    }
                }
            }
            .navigationTitle("Добавить транзакцию")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveTransaction()
                    }
                }
            }
        }
    }

    func saveTransaction() {
        guard let amountValue = Double(amount), !store.isEmpty else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: selectedDate)

        let transaction = Transaction(
            amount: amountValue,
            store: store,
            date: formattedDate,
            category: selectedCategory,
            type: selectedType
        )
        onSave(transaction)
        presentationMode.wrappedValue.dismiss()
    }
}
