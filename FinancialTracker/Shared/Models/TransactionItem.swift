import Foundation
import SwiftData

// SwiftData model for a transaction.
@Model
final class TransactionItem: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var subtitle: String = ""
    var date: Date = Date()
    var amount: Double = 0
    var typeRaw: String = TransactionType.expense.rawValue
    var accountRaw: String = AccountType.debitCard.rawValue
    var categoryTypeRaw: String = "expense"
    var categoryRaw: String = SpendingCategory.foodAndDining.rawValue

    // Initialize a persisted transaction.
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        date: Date,
        amount: Double,
        type: TransactionType,
        account: AccountType,
        category: TransactionCategory
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.amount = amount
        self.typeRaw = type.rawValue
        self.accountRaw = account.rawValue
        self.categoryTypeRaw = category.typeRaw
        self.categoryRaw = category.categoryRaw
    }

    // Accessor for transaction type enum.
    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    // Accessor for account enum.
    var account: AccountType {
        get { AccountType(rawValue: accountRaw) ?? .debitCard }
        set { accountRaw = newValue.rawValue }
    }

    // Accessor for category wrapper.
    var category: TransactionCategory {
        get { TransactionCategory(typeRaw: categoryTypeRaw, rawValue: categoryRaw) ?? .expense(.foodAndDining) }
        set {
            categoryTypeRaw = newValue.typeRaw
            categoryRaw = newValue.categoryRaw
        }
    }
}
