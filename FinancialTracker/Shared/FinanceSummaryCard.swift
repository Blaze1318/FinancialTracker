import SwiftUI

// Gradient summary card for account totals on the dashboard.
struct FinanceSummaryCard: View {
    let icon: String
    let iconIsAsset: Bool
    let title: String
    let amount: Double
    let gradientStart: Color
    let gradientEnd: Color

    // Initialize a summary card with gradient and content.
    init(
        icon: String,
        iconIsAsset: Bool = false,
        title: String,
        amount: Double,
        gradientStart: Color,
        gradientEnd: Color
    ) {
        self.icon = icon
        self.iconIsAsset = iconIsAsset
        self.title = title
        self.amount = amount
        self.gradientStart = gradientStart
        self.gradientEnd = gradientEnd
    }

    private var formattedAmount: String {
        FinanceSummaryCard.currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    // Card UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if iconIsAsset {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)

            Text(formattedAmount)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

private extension FinanceSummaryCard {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview("Finance Summary Card") {
    FinanceSummaryCard(
        icon: "creditcard",
        title: "Debit Card",
        amount: 2224.50,
        gradientStart: AppColors.green,
        gradientEnd: AppColors.teal
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
