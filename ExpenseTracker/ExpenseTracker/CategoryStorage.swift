import Foundation

class CategoryStorage {
    private let key = "categories"

    func saveCategories(_ categories: [Category]) {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadCategories() -> [Category] {
        if let data = UserDefaults.standard.data(forKey: key),
           let categories = try? JSONDecoder().decode([Category].self, from: data) {
            return categories
        }

        // Если категорий нет, загружаем дефолтные
        let defaultCategories = [
            Category(name: "Продукты"),
            Category(name: "Транспорт"),
            Category(name: "Развлечения"),
            Category(name: "Здоровье"),
            Category(name: "Одежда"),
            Category(name: "Прочее")
        ]
        saveCategories(defaultCategories)
        return defaultCategories
    }
    
    func addCategory(_ category: Category) {
        var categories = loadCategories()
        categories.append(category)
        saveCategories(categories)
    }

    func deleteCategory(_ category: Category) {
        var categories = loadCategories()
        categories.removeAll { $0.id == category.id }
        saveCategories(categories)
    }
}
