//
//  EditCategoryView.swift
//  ExpenseTracker
//
//  Created by Anton Levchuk on 09/02/2025.
//

import SwiftUI

struct EditCategoryView: View {
    @State var category: Category
    var onSave: (Category) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название категории")) {
                    TextField("Введите новое название", text: $category.name)
                }
            }
            .navigationTitle("Редактирование категории")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(category)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Удалить", role: .destructive) {
                        deleteCategory()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func deleteCategory() {
        var categories = CategoryStorage().loadCategories()
        categories.removeAll { $0.id == category.id }
        CategoryStorage().saveCategories(categories)
    }
}
