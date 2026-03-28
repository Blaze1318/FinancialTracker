import SwiftUI

// Unified category wrapper for income and expense categories.
enum TransactionCategory: Hashable {
    case expense(SpendingCategory)
    case income(IncomeCategory)
    case custom(String)

    var typeRaw: String {
        switch self {
        case .expense:
            return "expense"
        case .income:
            return "income"
        case .custom:
            return "custom"
        }
    }

    var categoryRaw: String {
        switch self {
        case .expense(let category):
            return category.rawValue
        case .income(let category):
            return category.rawValue
        case .custom(let name):
            return name
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
        case "custom":
            let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            self = .custom(trimmed.isEmpty ? "Custom" : trimmed)
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
        case .custom(let name):
            return name
        }
    }

    var iconName: String {
        switch self {
        case .expense(let category):
            return category.iconName
        case .income(let category):
            return category.iconName
        case .custom:
            return "tag"
        }
    }

    var accentColor: Color {
        switch self {
        case .expense(let category):
            return category.accentColor
        case .income(let category):
            return category.accentColor
        case .custom:
            return AppColors.blue
        }
    }

    var iconBackground: Color {
        switch self {
        case .expense(let category):
            return category.iconBackground
        case .income(let category):
            return category.iconBackground
        case .custom:
            return AppColors.blue.opacity(0.18)
        }
    }
}
