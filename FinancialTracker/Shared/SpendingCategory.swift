import SwiftUI

// Expense categories used in transactions and analytics.
enum SpendingCategory: String, CaseIterable {
    case shopping = "shopping"
    case billsAndUtilities = "billsAndUtilities"
    case entertainment = "entertainment"
    case foodAndDining = "foodAndDining"
    case transportation = "transportation"
    case miscellaneous = "miscellaneous"

    var title: String {
        switch self {
        case .shopping:
            return "Shopping"
        case .billsAndUtilities:
            return "Bills & Utilities"
        case .entertainment:
            return "Entertainment"
        case .foodAndDining:
            return "Food & Dining"
        case .transportation:
            return "Transportation"
        case .miscellaneous:
            return "Miscellaneous"
        }
    }

    var iconName: String {
        switch self {
        case .shopping:
            return "bag"
        case .billsAndUtilities:
            return "doc.text"
        case .entertainment:
            return "film"
        case .foodAndDining:
            return "cup.and.saucer"
        case .transportation:
            return "car"
        case .miscellaneous:
            return "ellipsis.circle"
        }
    }

    var accentColor: Color {
        switch self {
        case .shopping:
            return AppColors.purple
        case .billsAndUtilities:
            return Color.black.opacity(0.65)
        case .entertainment:
            return Color.orange
        case .foodAndDining:
            return AppColors.pink
        case .transportation:
            return AppColors.blue
        case .miscellaneous:
            return AppColors.coral
        }
    }

    var iconBackground: Color {
        accentColor.opacity(0.18)
    }
}
