import Foundation
import Combine
import SwiftUI

struct AIInsightsContext: Hashable {
    let month: Date
    let current: [TransactionSnapshot]
    let previous: [TransactionSnapshot]
    let totals: MonthlyTotals

    var cacheKey: String {
        "\(month.timeIntervalSince1970)-\(current.count)-\(previous.count)-\(totals.income)-\(totals.expense)"
    }
}

struct TransactionSnapshot: Hashable {
    let title: String
    let category: String
    let type: String
    let amount: Double
    let dateISO: String
}

struct MonthlyTotals: Hashable {
    let income: Double
    let expense: Double
    let net: Double
    let previousExpense: Double
}

protocol AIInsightsGenerating {
    func generateInsights(context: AIInsightsContext) async throws -> [AIInsight]
}

final class AIInsightsViewModel: ObservableObject {
    @Published var insights: [AIInsight] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let generator: AIInsightsGenerating

    init(generator: AIInsightsGenerating = SystemAIInsightsGenerator()) {
        self.generator = generator
    }

    @MainActor
    func generateInsights(using context: AIInsightsContext) async {
        isLoading = true
        errorMessage = nil
        if context.current.isEmpty && context.previous.isEmpty {
            insights = []
            isLoading = false
            return
        }
        do {
            let generated = try await generator.generateInsights(context: context)
            insights = generated
        } catch {
            insights = []
            errorMessage = (error as NSError).localizedDescription
        }
        isLoading = false
    }
}

final class SystemAIInsightsGenerator: AIInsightsGenerating {
    static var isAvailable: Bool {
#if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return true
        }
#endif
        return false
    }

    func generateInsights(context: AIInsightsContext) async throws -> [AIInsight] {
#if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return try await FoundationModelsInsightsGenerator().generateInsights(context: context)
        }
#endif
        throw NSError(domain: "AIInsights", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Apple Intelligence isn’t available on this device."
        ])
    }
}

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
final class FoundationModelsInsightsGenerator: AIInsightsGenerating {
    func generateInsights(context: AIInsightsContext) async throws -> [AIInsight] {
        let prompt = buildPrompt(from: context)
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        let payload = try decodeInsights(from: response.content)
        return payload.map { item in
            AIInsight(
                title: item.title,
                message: item.message,
                iconName: item.iconName,
                accent: Color(hex: item.accentHex),
                background: Color(hex: item.backgroundHex)
            )
        }
    }

    private func buildPrompt(from context: AIInsightsContext) -> String {
        let monthLabel = Self.monthFormatter.string(from: context.month)
        let hasCurrent = !context.current.isEmpty
        let transactions = context.current.map { tx in
            "\(tx.dateISO) | \(tx.type) | \(tx.category) | \(tx.title) | \(tx.amount)"
        }.joined(separator: "\n")

        let header = """
        You are a financial assistant within a budgeting application. Generate 3–5 concise insights for the month \(monthLabel).
        Focus ONLY on this month’s spending. Carefully identify areas for improvement and offer actionable recommendations. Do not compare to previous months.
        Use SF Symbols names for iconName (e.g., chart.line.uptrend.xyaxis, lightbulb, cart, target, banknote, calendar, sparkles).
        Choose accentHex ONLY from: 9810FA, 0A0A0A, 009966, 364153, 009689, 6A7282, 000000, 4F39F6.
        Choose backgroundHex ONLY from: FFFFFF, F3F4F6.
        Respond ONLY with JSON array where each item has:
        { "title": "...", "message": "...", "iconName": "...", "accentHex": "RRGGBB", "backgroundHex": "RRGGBB" }.
        """

        var sections: [String] = [header]

        if hasCurrent {
            sections.append("""
            Current month totals:
            income=\(context.totals.income), expense=\(context.totals.expense), net=\(context.totals.net)
            """)
        }

        if hasCurrent {
            sections.append("""
            Current month transactions:
            \(transactions)
            """)
        }

        return sections.joined(separator: "\n\n")
    }

    private func decodeInsights(from response: String) throws -> [AIInsightPayload] {
        guard let json = extractJSONArray(from: response),
              let data = json.data(using: .utf8) else {
            throw NSError(domain: "AIInsights", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Model response was not valid JSON."
            ])
        }
        return try JSONDecoder().decode([AIInsightPayload].self, from: data)
    }

    private func extractJSONArray(from response: String) -> String? {
        guard let start = response.firstIndex(of: "["),
              let end = response.lastIndex(of: "]"),
              start <= end else {
            return nil
        }
        return String(response[start...end])
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

private struct AIInsightPayload: Decodable {
    let title: String
    let message: String
    let iconName: String
    let accentHex: String
    let backgroundHex: String
}
#endif
