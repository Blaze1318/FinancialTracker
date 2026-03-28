import SwiftUI

struct GoalSummaryCard: View {
    let goal: Goal
    let onAddMoney: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        let accent = Color(hex: goal.colorHex)
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(accent.opacity(0.18))
                        .frame(width: 56, height: 56)
                    Text(goal.emoji)
                        .font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.name)
                        .font(.system(size: 18, weight: .bold))
                    if let deadline = goal.deadline {
                        Text("Target: \(Self.dateFormatter.string(from: deadline))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }

            HStack(alignment: .center) {
                Text("\(formatted(goal.currentAmount)) / \(formatted(goal.targetAmount))")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(accent)
            }

            ProgressView(value: goal.progress)
                .tint(accent)

            Button(action: onAddMoney) {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Add Money")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func formatted(_ value: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

private extension GoalSummaryCard {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
