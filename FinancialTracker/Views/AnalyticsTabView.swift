import SwiftUI
import UniformTypeIdentifiers
import UIKit

// Analytics tab content for the dashboard.
struct AnalyticsTabView: View {
    let spends: [CategorySpend]
    let summary: (income: Double, expenses: Double, net: Double)
    @State private var exportDocument: AnalyticsPDFDocument?
    @State private var isExporting = false
    @State private var isGeneratingPDF = false

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

        guard let data = AnalyticsPDFBuilder.buildPDF(spends: spends, summary: summary) else {
            return
        }
        exportDocument = AnalyticsPDFDocument(data: data)
        isExporting = true
    }
}

private struct AnalyticsExportContent: View {
    let spends: [CategorySpend]
    let summary: (income: Double, expenses: Double, net: Double)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics Summary")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(hex: "0A0A0A"))

            Text("Total Spending: \(summary.expenses.formatted(.currency(code: "USD")))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "364153"))

            SpendingByCategoryCard(spends: spends)
            TopSpendingCategoriesCard(spends: spends)
            AnalyticsSummaryCard(
                totalIncome: summary.income,
                totalExpenses: summary.expenses,
                netBalance: summary.net
            )
        }
        .padding(24)
        .background(Color.white)
    }
}

private enum AnalyticsPDFBuilder {
    static var defaultFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Analytics-\(formatter.string(from: Date()))"
    }

    @MainActor
    static func buildPDF(
        spends: [CategorySpend],
        summary: (income: Double, expenses: Double, net: Double)
    ) -> Data? {
        let pageSize = CGSize(width: 612, height: 792)
        let content = AnalyticsExportContent(spends: spends, summary: summary)
            .frame(width: pageSize.width - 64)
            .fixedSize(horizontal: false, vertical: true)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let image = renderer.uiImage else {
            return nil
        }

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return pdfRenderer.pdfData { context in
            context.beginPage()
            let available = CGRect(origin: .zero, size: pageSize)
            let scale = min(
                available.width / image.size.width,
                available.height / image.size.height
            )
            let drawSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            let origin = CGPoint(
                x: (available.width - drawSize.width) / 2,
                y: (available.height - drawSize.height) / 2
            )
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }
}

private struct AnalyticsPDFDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
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
