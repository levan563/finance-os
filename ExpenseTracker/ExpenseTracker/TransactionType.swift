//
//  TransactionType.swift
//  ExpenseTracker
//
//  Created by Anton Levchuk on 09/02/2025.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "Доход"
    case expense = "Расход"

    var id: String { self.rawValue }
}
