import Foundation
import SwiftData

@Model
final class Budget: Identifiable {
    var id: UUID = UUID()
    var monthKey: String = ""
    var monthDate: Date = Date()
    var categoryTypeRaw: String = "overall"
    var categoryRaw: String = ""
    var accountKindRaw: String = "system"
    var accountRaw: String = AccountType.debitCard.rawValue
    var customAccountIdRaw: String = ""
    var limitAmount: Double = 0
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        monthDate: Date,
        category: BudgetCategory,
        accountSelection: AccountSelection,
        limitAmount: Double
    ) {
        self.id = id
        self.monthDate = monthDate
        self.monthKey = Budget.monthKey(from: monthDate)
        self.categoryTypeRaw = category.typeRaw
        self.categoryRaw = category.rawValue
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
        self.limitAmount = limitAmount
        self.createdAt = Date()
    }

    var category: BudgetCategory {
        get { BudgetCategory(typeRaw: categoryTypeRaw, rawValue: categoryRaw) ?? .overall }
        set {
            categoryTypeRaw = newValue.typeRaw
            categoryRaw = newValue.rawValue
        }
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

    func isInMonth(_ date: Date) -> Bool {
        Budget.monthKey(from: date) == monthKey
    }

    static func monthKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
