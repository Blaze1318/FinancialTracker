import SwiftUI

// Unified category wrapper for income and expense categories.
enum TransactionCategory: Hashable {
    case expense(SpendingCategory)
    case income(IncomeCategory)

    var typeRaw: String {
        switch self {
        case .expense:
            return "expense"
        case .income:
            return "income"
        }
    }

    var categoryRaw: String {
        switch self {
        case .expense(let category):
            return category.rawValue
        case .income(let category):
            return category.rawValue
        }
    }

    init?(typeRaw: String, rawValue: String) {
        switch typeRaw {
        case "expense":
            guard let category = SpendingCategory(rawValue: rawValue) else { return nil }
            self = .expense(category)
        case "income":
            guard let category = IncomeCategory(rawValue: rawValue) else { return nil }
            self = .income(category)
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .expense(let category):
            return category.title
        case .income(let category):
            return category.title
        }
    }

    var iconName: String {
        switch self {
        case .expense(let category):
            return category.iconName
        case .income(let category):
            return category.iconName
        }
    }

    var accentColor: Color {
        switch self {
        case .expense(let category):
            return category.accentColor
        case .income(let category):
            return category.accentColor
        }
    }

    var iconBackground: Color {
        switch self {
        case .expense(let category):
            return category.iconBackground
        case .income(let category):
            return category.iconBackground
        }
    }
}
