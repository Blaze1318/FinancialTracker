import Foundation

// Account buckets used for filtering and balances.
enum AccountType: String, CaseIterable, Identifiable {
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case savings = "Savings"

    var id: String { rawValue }
}
