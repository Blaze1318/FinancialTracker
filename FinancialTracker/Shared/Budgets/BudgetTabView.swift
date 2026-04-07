import SwiftUI

struct BudgetTabView: View {
    let budgets: [Budget]
    let transactions: [TransactionItem]
    let selectedMonth: Date
    let selectedSummary: AccountSummary
    let customAccountsById: [UUID: CustomAccount]
    let onCreate: () -> Void
    let onEdit: (Budget) -> Void
    let onDelete: (Budget) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Budgets")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button {
                    onCreate()
                } label: {
                    Label("New", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColors.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(monthLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            VStack(spacing: 14) {
                ForEach(budgetsForMonth) { budget in
                    BudgetCard(
                        title: budget.category.title,
                        accountName: accountName(for: budget),
                        amountSpent: spentAmount(for: budget),
                        limitAmount: budget.limitAmount,
                        accent: AppColors.green,
                        onEdit: { onEdit(budget) },
                        onDelete: { onDelete(budget) }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private var budgetsForMonth: [Budget] {
        budgets.filter { budget in
            guard budget.isInMonth(selectedMonth) else { return false }
            switch selectedSummary {
            case .all:
                return true
            case .system(let account):
                return budget.accountSelection == .system(account)
            case .custom(let id):
                return budget.accountSelection == .custom(id)
            }
        }
        .sorted { $0.createdAt < $1.createdAt }
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private func spentAmount(for budget: Budget) -> Double {
        let monthFiltered = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }
        let accountFiltered = monthFiltered.filter { $0.accountSelection == budget.accountSelection }
        let expenseFiltered = accountFiltered.filter { $0.type == .expense }
        switch budget.category {
        case .overall:
            return expenseFiltered.reduce(0) { $0 + $1.amount }
        case .expense(let category):
            return expenseFiltered.filter { transaction in
                if case .expense(let current) = transaction.category {
                    return current.rawValue == category.rawValue
                }
                return false
            }.reduce(0) { $0 + $1.amount }
        case .custom(let name):
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let target = trimmed.isEmpty ? "Custom" : trimmed
            return expenseFiltered.filter { transaction in
                if case .custom(let current) = transaction.category {
                    return current == target
                }
                return false
            }.reduce(0) { $0 + $1.amount }
        }
    }

    private func accountName(for budget: Budget) -> String {
        switch budget.accountSelection {
        case .system(let account):
            return account.rawValue
        case .custom(let id):
            return customAccountsById[id]?.name ?? "Custom Account"
        }
    }
}
