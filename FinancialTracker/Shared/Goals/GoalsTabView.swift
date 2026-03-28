import SwiftUI

struct GoalsTabView: View {
    let goals: [Goal]
    let onCreate: () -> Void
    let onEdit: (Goal) -> Void
    let onDelete: (Goal) -> Void
    let onAddMoney: (Goal) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Savings Goals")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("\(goals.count) \(goals.count == 1 ? "goal" : "goals")")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            VStack(spacing: 14) {
                ForEach(goals) { goal in
                    GoalSummaryCard(
                        goal: goal,
                        onAddMoney: { onAddMoney(goal) },
                        onEdit: { onEdit(goal) },
                        onDelete: { onDelete(goal) }
                    )
                }

                Button(action: onCreate) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Create New Goal")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .foregroundStyle(Color.black.opacity(0.2))
                    )
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
