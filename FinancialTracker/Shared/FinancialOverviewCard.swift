import SwiftUI

// Large overview card showing total balance and income/expenses.
struct FinancialOverviewCard: View {
    let title: String
    let totalAmount: Double
    let incomeAmount: Double
    let expensesAmount: Double
    let gradientStart: Color
    let gradientEnd: Color

    // Card UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "creditcard")
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(.white)

            Text(Self.currencyFormatter.string(from: NSNumber(value: totalAmount)) ?? "$0")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 14) {
                MiniStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Income",
                    amount: incomeAmount
                )
                MiniStatCard(
                    icon: "chart.line.downtrend.xyaxis",
                    title: "Expenses",
                    amount: expensesAmount
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private extension FinancialOverviewCard {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// Small stat card used inside the overview card.
private struct MiniStatCard: View {
    let icon: String
    let title: String
    let amount: Double

    // Mini stat UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.9))

            Text(FinancialOverviewCard.currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview("Financial Overview Card") {
    FinancialOverviewCard(
        title: "Total Balance",
        totalAmount: 2369.50,
        incomeAmount: 3000.00,
        expensesAmount: 630.50,
        gradientStart: AppColors.blue,
        gradientEnd: AppColors.cyan
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
