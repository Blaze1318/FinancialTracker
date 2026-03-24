import SwiftUI

// Analytics tab content for the dashboard.
struct AnalyticsTabView: View {
    let spends: [CategorySpend]
    let summary: (income: Double, expenses: Double, net: Double)

    // Tab UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SpendingByCategoryCard(spends: spends)
                .padding(.horizontal, 12)

            TopSpendingCategoriesCard(spends: spends)
                .padding(.horizontal, 12)

            AnalyticsSummaryCard(
                totalIncome: summary.income,
                totalExpenses: summary.expenses,
                netBalance: summary.net
            )
            .padding(.horizontal, 12)
        }
    }
}

#Preview("Analytics Tab") {
    AnalyticsTabView(
        spends: [
            CategorySpend(title: "Shopping", amount: 270, color: AppColors.purple),
            CategorySpend(title: "Bills & Utilities", amount: 200, color: Color.black.opacity(0.65)),
            CategorySpend(title: "Entertainment", amount: 85, color: Color.orange),
            CategorySpend(title: "Food & Dining", amount: 45.5, color: AppColors.pink),
            CategorySpend(title: "Transportation", amount: 30, color: AppColors.blue)
        ],
        summary: (income: 3000, expenses: 630.5, net: 2369.5)
    )
}
