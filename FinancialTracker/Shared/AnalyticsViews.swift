import SwiftUI

// Data model for category spend used in analytics cards.
struct CategorySpend: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let color: Color
}

struct SpendingByCategoryCard: View {
    let spends: [CategorySpend]

    // Card UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 18, weight: .semibold))
                Text("Spending by Category")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(.primary)

            HStack(spacing: 16) {
                PieChartView(slices: slices)
                    .frame(width: 160, height: 160)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(slices) { slice in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(slice.color)
                                .frame(width: 10, height: 10)
                            Text("\(slice.title) \(slice.percentText)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(slice.color)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private var slices: [PieSlice] {
        let total = spends.map(\.amount).reduce(0, +)
        guard total > 0 else { return [] }
        var start: Double = 0
        return spends.map { spend in
            let fraction = spend.amount / total
            let slice = PieSlice(
                title: spend.title,
                amount: spend.amount,
                color: spend.color,
                startAngle: .degrees(start * 360 - 90),
                endAngle: .degrees((start + fraction) * 360 - 90),
                percent: fraction
            )
            start += fraction
            return slice
        }
    }
}

struct TopSpendingCategoriesCard: View {
    let spends: [CategorySpend]

    // Card UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Top Spending Categories")
                .font(.system(size: 20, weight: .bold))

            VStack(spacing: 14) {
                ForEach(spends) { spend in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(spend.title)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text(Self.currencyFormatter.string(from: NSNumber(value: spend.amount)) ?? "$0")
                                .font(.system(size: 16, weight: .semibold))
                        }

                        GeometryReader { proxy in
                            let width = proxy.size.width
                            let ratio = maxAmount == 0 ? 0 : spend.amount / maxAmount
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.black.opacity(0.06))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(spend.color)
                                    .frame(width: width * ratio, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private var maxAmount: Double {
        spends.map(\.amount).max() ?? 0
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

struct AnalyticsSummaryCard: View {
    let totalIncome: Double
    let totalExpenses: Double
    let netBalance: Double

    // Card UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Summary")
                .font(.system(size: 20, weight: .bold))

            VStack(spacing: 14) {
                summaryRow(title: "Total Income", value: totalIncome, color: AppColors.green, sign: "+")
                summaryRow(title: "Total Expenses", value: totalExpenses, color: AppColors.pink, sign: "-")

                Divider()
                    .background(Color.black.opacity(0.1))

                summaryRow(
                    title: "Net Balance",
                    value: netBalance,
                    color: netBalance >= 0 ? AppColors.green : AppColors.pink,
                    sign: netBalance >= 0 ? "+" : "-"
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    @ViewBuilder
    // Row renderer for a summary line.
    private func summaryRow(title: String, value: Double, color: Color, sign: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text("\(sign)\(Self.currencyFormatter.string(from: NSNumber(value: abs(value))) ?? "$0")")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
        }
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// Internal model for pie chart slices.
private struct PieSlice: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let color: Color
    let startAngle: Angle
    let endAngle: Angle
    let percent: Double

    var percentText: String {
        let value = Int(round(percent * 100))
        return "\(value)%"
    }
}

// Simple pie chart for category spending.
private struct PieChartView: View {
    let slices: [PieSlice]

    // Chart UI.
    var body: some View {
        ZStack {
            ForEach(slices) { slice in
                PieSliceShape(startAngle: slice.startAngle, endAngle: slice.endAngle)
                    .fill(slice.color)
            }
        }
    }
}

// Pie slice path shape.
private struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    // Build the slice path.
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
