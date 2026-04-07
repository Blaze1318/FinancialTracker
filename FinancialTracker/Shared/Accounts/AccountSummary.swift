import SwiftUI

enum AccountSummary: Hashable, Identifiable {
    case all
    case system(AccountType)
    case custom(UUID)

    var id: String {
        switch self {
        case .all:
            return "all"
        case .system(let type):
            return "system-\(type.rawValue)"
        case .custom(let id):
            return "custom-\(id.uuidString)"
        }
    }
}

extension AccountSummary {
    func title(customAccountsById: [UUID: CustomAccount]) -> String {
        switch self {
        case .all:
            return "All Accounts"
        case .system(let account):
            return account.rawValue
        case .custom(let id):
            return customAccountsById[id]?.name ?? "Custom Account"
        }
    }

    func iconName(customAccountsById: [UUID: CustomAccount]) -> String {
        switch self {
        case .all:
            return "wallet.pass"
        case .system(let account):
            switch account {
            case .debitCard, .creditCard:
                return "creditcard"
            case .savings:
                return "dollarsign.circle.fill"
            }
        case .custom(let id):
            return customAccountsById[id]?.iconName ?? "wallet.pass"
        }
    }

    func iconIsAsset(customAccountsById: [UUID: CustomAccount]) -> Bool {
        switch self {
        case .custom(let id):
            let icon = customAccountsById[id]?.iconName ?? ""
            return assetIconNames.contains(icon)
        default:
            return false
        }
    }

    func gradientStart(customAccountsById: [UUID: CustomAccount]) -> Color {
        switch self {
        case .all:
            return AppColors.blue
        case .system(let account):
            switch account {
            case .debitCard:
                return AppColors.green
            case .creditCard:
                return AppColors.pink
            case .savings:
                return AppColors.purple
            }
        case .custom(let id):
            return customAccountsById[id]?.color ?? AppColors.blue
        }
    }

    func gradientEnd(customAccountsById: [UUID: CustomAccount]) -> Color {
        switch self {
        case .all:
            return AppColors.cyan
        case .system(let account):
            switch account {
            case .debitCard:
                return AppColors.teal
            case .creditCard:
                return AppColors.coral
            case .savings:
                return AppColors.lavender
            }
        case .custom(let id):
            return (customAccountsById[id]?.color ?? AppColors.blue).opacity(0.85)
        }
    }

    func accent(customAccountsById: [UUID: CustomAccount]) -> Color {
        switch self {
        case .all:
            return AppColors.cyan
        case .system(let account):
            switch account {
            case .debitCard:
                return AppColors.teal
            case .creditCard:
                return AppColors.coral
            case .savings:
                return AppColors.lavender
            }
        case .custom(let id):
            return customAccountsById[id]?.color ?? AppColors.blue
        }
    }

    private var assetIconNames: Set<String> {
        ["piggybank"]
    }
}
