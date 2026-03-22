import SwiftUI

// Transactions tab content for the dashboard.
struct TransactionsTabView: View {
    let transactions: [TransactionItem]
    let totalCount: Int
    let onSelect: (TransactionItem) -> Void

    // Tab UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(totalCount) transactions")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            VStack(spacing: 14) {
                ForEach(transactions) { transaction in
                    TransactionRowCard(
                        category: transaction.category,
                        title: transaction.title,
                        subtitle: transaction.subtitle,
                        date: transaction.date,
                        amount: transaction.amount,
                        type: transaction.type
                    )
                    .onTapGesture {
                        onSelect(transaction)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview("Transactions Tab") {
    TransactionsTabView(
        transactions: [
            TransactionItem(
                title: "Food & Dining",
                subtitle: "Lunch at cafe",
                date: Date(),
                amount: 45.50,
                type: .expense,
                account: .debitCard,
                category: .expense(.foodAndDining)
            )
        ],
        totalCount: 1,
        onSelect: { _ in }
    )
}
