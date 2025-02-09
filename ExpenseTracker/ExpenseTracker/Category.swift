//
//  Category.swift
//  ExpenseTracker
//
//  Created by Anton Levchuk on 09/02/2025.
//

import Foundation

struct Category: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
}
