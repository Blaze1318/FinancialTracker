import SwiftUI

struct BudgetCard: View {
    let title: String
    let accountName: String
    let amountSpent: Double
    let limitAmount: Double
    let accent: Color
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "0A0A0A"))
                    Text(accountName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.black)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(amountSpent.formatted(.currency(code: "USD")))
                    .font(.system(size: 22, weight: .bold))
                Text("/ \(limitAmount.formatted(.currency(code: "USD")))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(accent)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack {
                Text("\(Int(progress * 100))% used")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(remaining.formatted(.currency(code: "USD"))) left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.green.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.green.opacity(0.18), lineWidth: 1)
        )
    }

    private var progress: Double {
        guard limitAmount > 0 else { return 0 }
        return min(amountSpent / limitAmount, 1)
    }

    private var remaining: Double {
        max(limitAmount - amountSpent, 0)
    }
}
