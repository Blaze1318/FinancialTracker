import SwiftUI
import UniformTypeIdentifiers

// Transactions tab content for the dashboard.
struct TransactionsTabView: View {
    let transactions: [TransactionItem]
    let exportTransactions: [TransactionItem]
    let totalCount: Int
    let summaryTitle: String
    let summaryTotal: Double
    let exportFilename: String
    let onSelect: (TransactionItem) -> Void
    @State private var exportDocument: TransactionsCSVDocument?
    @State private var isExporting = false

    // Tab UI.
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button {
                    exportCSV()
                } label: {
                    Label("Download", systemImage: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.bordered)
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
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: exportFilename
        ) { result in
            exportDocument = nil
        }
    }

    private func exportCSV() {
        guard let data = TransactionsCSVBuilder.buildCSV(
            transactions: exportTransactions,
            summaryTitle: summaryTitle,
            summaryTotal: summaryTotal
        ) else { return }
        exportDocument = TransactionsCSVDocument(data: data)
        isExporting = true
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
        exportTransactions: [],
        totalCount: 1,
        summaryTitle: "All Accounts",
        summaryTotal: 450.0,
        exportFilename: "Transactions-All-Accounts-2026-03-28",
        onSelect: { _ in }
    )
}
