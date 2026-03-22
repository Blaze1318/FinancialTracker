import SwiftUI

// Income categories used for income transactions.
enum IncomeCategory: String, CaseIterable {
    case salary = "salary"
    case freelance = "freelance"
    case rentalIncome = "rentalIncome"
    case dividends = "dividends"
    case contract = "contract"

    var title: String {
        switch self {
        case .salary:
            return "Salary"
        case .freelance:
            return "Freelance"
        case .rentalIncome:
            return "Rental Income"
        case .dividends:
            return "Dividends"
        case .contract:
            return "Contract"
        }
    }

    var iconName: String {
        switch self {
        case .salary:
            return "briefcase"
        case .freelance:
            return "dollarsign.circle"
        case .rentalIncome:
            return "house"
        case .dividends:
            return "chart.pie"
        case .contract:
            return "doc.text"
        }
    }

    var accentColor: Color {
        AppColors.green
    }

    var iconBackground: Color {
        AppColors.green.opacity(0.18)
    }
}
