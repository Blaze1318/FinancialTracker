
import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct TransactionsCSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

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

enum TransactionsCSVBuilder {
    static func defaultFilename(summaryTitle: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let sanitized = summaryTitle.replacingOccurrences(of: " ", with: "-")
        return "Transactions-\(sanitized)-\(formatter.string(from: Date())).csv"
    }

    static func buildCSV(
        transactions: [TransactionItem],
        summaryTitle: String,
        summaryTotal: Double
    ) -> Data? {
        var rows: [String] = []
        let incomeTransactions = transactions.filter { $0.type == .income }
        let expenseTransactions = transactions.filter { $0.type == .expense }
        let totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }
        let totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
        let netTotal = totalIncome - totalExpense

        rows.append("Summary")
        rows.append("Selected Summary,\(summaryTitle)")
        rows.append("Selected Total,\(formatAmount(summaryTotal))")
        rows.append("Income Total,\(formatAmount(totalIncome))")
        rows.append("Expense Total,\(formatAmount(totalExpense))")
        rows.append("Net Total,\(formatAmount(netTotal))")
        rows.append("")

        rows.append("Income Transactions")
        rows.append("Date,Title,Category,Account,Amount,Description")
        for transaction in incomeTransactions {
            rows.append([
                dateFormatter.string(from: transaction.date),
                escapeCSV(transaction.title),
                escapeCSV(transaction.category.title),
                transaction.account.rawValue,
                escapeCSV(formatAmount(transaction.amount)),
                escapeCSV(transaction.subtitle)
            ].joined(separator: ","))
        }
        rows.append("")

        rows.append("Expense Transactions")
        rows.append("Date,Title,Category,Account,Amount,Description")
        for transaction in expenseTransactions {
            rows.append([
                dateFormatter.string(from: transaction.date),
                escapeCSV(transaction.title),
                escapeCSV(transaction.category.title),
                transaction.account.rawValue,
                escapeCSV(formatAmount(transaction.amount)),
                escapeCSV(transaction.subtitle)
            ].joined(separator: ","))
        }

        rows.append("")
        rows.append("Income Category Totals")
        rows.append("Category,Type,Total")

        let incomeGrouped = Dictionary(grouping: incomeTransactions, by: { $0.category.title })
        let incomeSorted = incomeGrouped.keys.sorted()
        for key in incomeSorted {
            let total = incomeGrouped[key, default: []].reduce(0) { $0 + $1.amount }
            rows.append("\(escapeCSV(key)),income,\(escapeCSV(formatAmount(total)))")
        }

        rows.append("")
        rows.append("Expense Category Totals")
        rows.append("Category,Type,Total")

        let expenseGrouped = Dictionary(grouping: expenseTransactions, by: { $0.category.title })
        let expenseSorted = expenseGrouped.keys.sorted()
        for key in expenseSorted {
            let total = expenseGrouped[key, default: []].reduce(0) { $0 + $1.amount }
            rows.append("\(escapeCSV(key)),expense,\(escapeCSV(formatAmount(total)))")
        }

        let csv = rows.joined(separator: "\n")
        return csv.data(using: .utf8)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    private static func escapeCSV(_ value: String) -> String {
        let needsQuotes = value.contains(",") || value.contains("\"") || value.contains("\n")
        if needsQuotes {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    private static func formatAmount(_ value: Double) -> String {
        amountFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
