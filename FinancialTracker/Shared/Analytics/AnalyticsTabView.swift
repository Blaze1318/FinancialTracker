import SwiftUI
import UniformTypeIdentifiers

// Analytics tab content for the dashboard.
struct AnalyticsTabView: View {
    let spends: [CategorySpend]
    let summary: (income: Double, expenses: Double, net: Double)
    @State private var exportDocument: AnalyticsPDFDocument?
    @State private var isExporting = false
    @State private var isGeneratingPDF = false
    let totalForSelectedSummary: Double

    // Tab UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Analytics")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button {
                    Task { await generatePDF() }
                } label: {
                    Label("Download", systemImage: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .disabled(isGeneratingPDF)
            }
            .padding(.horizontal, 12)

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
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .pdf,
            defaultFilename: AnalyticsPDFBuilder.defaultFilename
        ) { _ in
            exportDocument = nil
        }
    }

    @MainActor
    private func generatePDF() async {
        isGeneratingPDF = true
        defer { isGeneratingPDF = false }

        guard let data = AnalyticsPDFBuilder.buildPDF(
            spends: spends,
            summary: summary,
            totalForSelectedSummary: totalForSelectedSummary
        ) else {
            return
        }
        exportDocument = AnalyticsPDFDocument(data: data)
        isExporting = true
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
        summary: (income: 3000, expenses: 630.5, net: 2369.5),
        totalForSelectedSummary: 4100
    )
}
