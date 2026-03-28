import Foundation
import SwiftData

// SwiftData model for account balances.
@Model
final class Account: Identifiable {
    var id: UUID = UUID()
    var typeRaw: String = AccountType.debitCard.rawValue
    var baseBalance: Double = 0

    // Initialize a persisted account.
    init(id: UUID = UUID(), type: AccountType, baseBalance: Double) {
        self.id = id
        self.typeRaw = type.rawValue
        self.baseBalance = baseBalance
    }

    // Accessor for account type enum.
    var type: AccountType {
        get { AccountType.resolve(typeRaw) }
        set { typeRaw = newValue.rawValue }
    }
}
