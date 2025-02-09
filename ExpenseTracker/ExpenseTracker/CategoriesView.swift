import SwiftUI

struct CategoriesView: View {
    @State private var categories: [Category] = CategoryStorage().loadCategories()
    @State private var newCategoryName: String = ""
    @State private var selectedCategory: Category?
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                selectedCategory = category
                                isEditing = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteCategory) // Свайп для удаления
                }
                .navigationTitle("Категории")

                HStack {
                    TextField("Новая категория", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addCategory) {
                        Text("Добавить")
                    }
                }
                .padding()

                // Кнопка возврата к списку транзакций
                NavigationLink(destination: ContentView()) {
                    Text("Назад к транзакциям")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(item: $selectedCategory) { category in
            EditCategoryView(category: category, onSave: { updatedCategory in
                updateCategory(updatedCategory)
            })
        }
    }

    func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let newCategory = Category(name: newCategoryName)
        categories.append(newCategory)
        CategoryStorage().saveCategories(categories)
        newCategoryName = ""
    }

    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        CategoryStorage().saveCategories(categories)
    }

    func updateCategory(_ updatedCategory: Category) {
        if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
            categories[index] = updatedCategory
            CategoryStorage().saveCategories(categories)
        }
    }
}
