import Foundation

struct Transaction: Codable, Identifiable {
    var id: UUID // ✅ Убрали авто-генерацию ID!
    var amount: Double
    var store: String
    var date: String
    var category: Category?
    var type: TransactionType
    var year: Int
    var month: Int

    init(id: UUID = UUID(), amount: Double, store: String, date: String, category: Category?, type: TransactionType) {
        self.id = id
        self.amount = amount
        self.store = store
        self.date = date
        self.category = category
        self.type = type

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let transactionDate = dateFormatter.date(from: date) {
            let calendar = Calendar.current
            self.year = calendar.component(.year, from: transactionDate)
            self.month = calendar.component(.month, from: transactionDate)
        } else {
            let currentDate = Date()
            let calendar = Calendar.current
            self.year = calendar.component(.year, from: currentDate)
            self.month = calendar.component(.month, from: currentDate)
        }
    }

    // Добавляем вручную методы для кодирования и декодирования
    enum CodingKeys: String, CodingKey {
        case id, amount, store, date, category, type, year, month
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id) // ✅ Теперь ID загружается правильно!
        amount = try container.decode(Double.self, forKey: .amount)
        store = try container.decode(String.self, forKey: .store)
        date = try container.decode(String.self, forKey: .date)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
        type = try container.decode(TransactionType.self, forKey: .type)
        year = try container.decode(Int.self, forKey: .year)
        month = try container.decode(Int.self, forKey: .month)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(store, forKey: .store)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encode(type, forKey: .type)
        try container.encode(year, forKey: .year)
        try container.encode(month, forKey: .month)
    }
}
