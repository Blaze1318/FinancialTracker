import SwiftUI

enum BudgetCategory: Hashable {
    case overall
    case expense(SpendingCategory)
    case custom(String)

    var typeRaw: String {
        switch self {
        case .overall:
            return "overall"
        case .expense:
            return "expense"
        case .custom:
            return "custom"
        }
    }

    var rawValue: String {
        switch self {
        case .overall:
            return "Overall"
        case .expense(let category):
            return category.rawValue
        case .custom(let name):
            return name
        }
    }

    init?(typeRaw: String, rawValue: String) {
        switch typeRaw {
        case "overall":
            self = .overall
        case "expense":
            guard let category = SpendingCategory(rawValue: rawValue) else { return nil }
            self = .expense(category)
        case "custom":
            let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            self = .custom(trimmed.isEmpty ? "Custom" : trimmed)
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .overall:
            return "Overall"
        case .expense(let category):
            return category.title
        case .custom(let name):
            return name
        }
    }
}
