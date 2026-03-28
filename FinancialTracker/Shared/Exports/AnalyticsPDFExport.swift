import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct AnalyticsPDFDocument: FileDocument {
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

enum AnalyticsPDFBuilder {
    static var defaultFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Analytics-\(formatter.string(from: Date()))"
    }

    @MainActor
    static func buildPDF(
        spends: [CategorySpend],
        summary: (income: Double, expenses: Double, net: Double),
        totalForSelectedSummary: Double
    ) -> Data? {
        let pageSize = CGSize(width: 612, height: 792)
        let content = AnalyticsExportContent(
            spends: spends,
            summary: summary,
            totalForSelectedSummary: totalForSelectedSummary
        )
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

private struct AnalyticsExportContent: View {
    let spends: [CategorySpend]
    let summary: (income: Double, expenses: Double, net: Double)
    let totalForSelectedSummary: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics Summary")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(hex: "0A0A0A"))

            Text("Selected Total: \(totalForSelectedSummary.formatted(.currency(code: "USD")))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "364153"))

            Text("Total Spending: \(summary.expenses.formatted(.currency(code: "USD")))")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "6A7282"))

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
