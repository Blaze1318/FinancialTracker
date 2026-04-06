import Foundation

extension TransactionItem {
    func accountDisplayName(customAccountsById: [UUID: CustomAccount]) -> String {
        switch accountSelection {
        case .system(let account):
            return account.rawValue
        case .custom(let id):
            return customAccountsById[id]?.name ?? "Custom Account"
        }
    }
}
