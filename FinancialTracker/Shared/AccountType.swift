import Foundation

// Account buckets used for filtering and balances.
enum AccountType: String, CaseIterable, Identifiable {
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case savings = "Savings"

    var id: String { rawValue }
}

extension AccountType {
    static func resolve(_ raw: String) -> AccountType {
        let normalized = raw
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "_", with: "")
        switch normalized {
        case "creditcard", "credit":
            return .creditCard
        case "savings", "saving":
            return .savings
        case "debitcard", "debit":
            return .debitCard
        default:
            return .debitCard
        }
    }
}
