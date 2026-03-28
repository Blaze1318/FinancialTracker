import SwiftUI

// Row card for a single transaction entry.
struct TransactionRowCard: View {
    let category: TransactionCategory
    let title: String
    let subtitle: String
    let date: Date
    let amount: Double
    let type: TransactionType

    // Row UI.
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.iconBackground)
                    .frame(width: 54, height: 54)
                Image(systemName: category.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(category.accentColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.green)
                    Text(Self.dateFormatter.string(from: date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 10)

            Text("\(type.sign)\(formattedAmount)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(type.amountColor)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private var formattedAmount: String {
        TransactionRowCard.currencyFormatter.string(from: NSNumber(value: abs(amount))) ?? "$0"
    }
}

private extension TransactionRowCard {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

#Preview("Transaction Row Card") {
    VStack(spacing: 16) {
        TransactionRowCard(
            category: .expense(.foodAndDining),
            title: "Food & Dining",
            subtitle: "Lunch at cafe",
            date: Date(),
            amount: 45.50,
            type: .expense
        )
        TransactionRowCard(
            category: .expense(.shopping),
            title: "Shopping",
            subtitle: "New shoes",
            date: Date(),
            amount: 120.00,
            type: .expense
        )
        TransactionRowCard(
            category: .expense(.entertainment),
            title: "Entertainment",
            subtitle: "Concert tickets",
            date: Date(),
            amount: 85.00,
            type: .expense
        )
        TransactionRowCard(
            category: .expense(.billsAndUtilities),
            title: "Bills & Utilities",
            subtitle: "Electric bill",
            date: Date(),
            amount: 200.00,
            type: .expense
        )
        TransactionRowCard(
            category: .expense(.transportation),
            title: "Transportation",
            subtitle: "Gas",
            date: Date(),
            amount: 30.00,
            type: .expense
        )
        TransactionRowCard(
            category: .income(.salary),
            title: "Salary",
            subtitle: "Monthly salary",
            date: Date(),
            amount: 2500.00,
            type: .income
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
