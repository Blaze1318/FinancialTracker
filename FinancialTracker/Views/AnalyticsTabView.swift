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
            CategorySpend(category: .shopping, amount: 270),
            CategorySpend(category: .billsAndUtilities, amount: 200),
            CategorySpend(category: .entertainment, amount: 85),
            CategorySpend(category: .foodAndDining, amount: 45.5),
            CategorySpend(category: .transportation, amount: 30)
        ],
        summary: (income: 3000, expenses: 630.5, net: 2369.5)
    )
}
