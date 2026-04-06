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
    var accountKindRaw: String = "system"
    var customAccountIdRaw: String = ""
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
        self.accountKindRaw = "system"
        self.customAccountIdRaw = ""
        self.categoryTypeRaw = category.typeRaw
        self.categoryRaw = category.categoryRaw
    }

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        date: Date,
        amount: Double,
        type: TransactionType,
        accountSelection: AccountSelection,
        category: TransactionCategory
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.amount = amount
        self.typeRaw = type.rawValue
        self.categoryTypeRaw = category.typeRaw
        self.categoryRaw = category.categoryRaw
        switch accountSelection {
        case .system(let account):
            self.accountKindRaw = "system"
            self.accountRaw = account.rawValue
            self.customAccountIdRaw = ""
        case .custom(let id):
            self.accountKindRaw = "custom"
            self.customAccountIdRaw = id.uuidString
            self.accountRaw = ""
        }
    }

    // Accessor for transaction type enum.
    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    // Accessor for account enum.
    var account: AccountType {
        get { AccountType.resolve(accountRaw) }
        set { accountRaw = newValue.rawValue }
    }

    var accountSelection: AccountSelection {
        get {
            if accountKindRaw == "custom",
               let id = UUID(uuidString: customAccountIdRaw) {
                return .custom(id)
            }
            return .system(AccountType.resolve(accountRaw))
        }
        set {
            switch newValue {
            case .system(let account):
                accountKindRaw = "system"
                accountRaw = account.rawValue
                customAccountIdRaw = ""
            case .custom(let id):
                accountKindRaw = "custom"
                customAccountIdRaw = id.uuidString
                accountRaw = ""
            }
        }
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
