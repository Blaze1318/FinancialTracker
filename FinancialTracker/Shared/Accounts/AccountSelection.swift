import Foundation

enum AccountSelection: Hashable, Identifiable {
    case system(AccountType)
    case custom(UUID)

    var id: String {
        switch self {
        case .system(let type):
            return "system-\(type.rawValue)"
        case .custom(let id):
            return "custom-\(id.uuidString)"
        }
    }
}
