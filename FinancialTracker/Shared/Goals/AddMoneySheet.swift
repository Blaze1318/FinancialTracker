import SwiftUI
import SwiftData

struct AddMoneySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    let goal: Goal
    let onGoalCompleted: () -> Void

    @State private var amountValue: Decimal = 0

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }

            VStack(spacing: 6) {
                Text("Add Money")
                    .font(.system(size: 22, weight: .bold))
                Text("Add funds to \(goal.name)")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.system(size: 16, weight: .semibold))
                TextField("$0.00", value: $amountValue, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button {
                let amount = NSDecimalNumber(decimal: amountValue).doubleValue
                guard amount > 0 else { return }
                goal.currentAmount += amount
                if goal.currentAmount >= goal.targetAmount && goal.targetAmount > 0 {
                    onGoalCompleted()
                }
                try? modelContext.save()
                isPresented = false
            } label: {
                Text("Add Funds")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 6)
        }
        .padding(20)
    }
}
