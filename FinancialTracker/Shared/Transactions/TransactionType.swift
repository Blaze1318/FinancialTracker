import SwiftUI

// Transaction direction for formatting and styling.
enum TransactionType: String {
    case income = "income"
    case expense = "expense"

    var amountColor: Color {
        switch self {
        case .income:
            return AppColors.green
        case .expense:
            return AppColors.pink
        }
    }

    var sign: String {
        switch self {
        case .income:
            return "+"
        case .expense:
            return "-"
        }
    }
}
