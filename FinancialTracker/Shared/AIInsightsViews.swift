import SwiftUI

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let iconName: String
    let accent: Color
    let background: Color
}

struct AIInsightsTabView: View {
    let context: AIInsightsContext
    @StateObject private var viewModel = AIInsightsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.purple)
                Text("AI Insights")
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 12)

            Text("Personalized recommendations based on your spending patterns")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)

            VStack(spacing: 14) {
                if !SystemAIInsightsGenerator.isAvailable {
                    AIInsightCard(insight: AIInsight(
                        title: "Apple Intelligence Unavailable",
                        message: "This device doesn’t support Apple Intelligence. Insights require a supported device and system settings enabled.",
                        iconName: "sparkles",
                        accent: AppColors.purple,
                        background: Color(hex: "F3F4F6")
                    ))
                } else if viewModel.isLoading {
                    ProgressView("Generating insights…")
                        .padding(.vertical, 12)
                } else if let error = viewModel.errorMessage {
                    AIInsightCard(insight: AIInsight(
                        title: "AI Unavailable",
                        message: error,
                        iconName: "exclamationmark.triangle",
                        accent: AppColors.coral,
                        background: AppColors.coral.opacity(0.12)
                    ))
                } else if viewModel.insights.isEmpty {
                    AIInsightCard(insight: AIInsight(
                        title: "Not Enough Data",
                        message: "Add a few transactions this month to unlock personalized insights.",
                        iconName: "info.circle",
                        accent: AppColors.blue,
                        background: AppColors.blue.opacity(0.12)
                    ))
                } else {
                    ForEach(viewModel.insights) { insight in
                        AIInsightCard(insight: insight)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .task(id: context.cacheKey) {
            await viewModel.generateInsights(using: context)
        }
    }
}

private struct AIInsightCard: View {
    let insight: AIInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.iconName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(insight.accent)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(insight.accent)
                Text(insight.message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(hex: "0A0A0A"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(insight.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: "F3F4F6"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 8)
    }
}
