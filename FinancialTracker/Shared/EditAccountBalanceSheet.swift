import SwiftUI

// Sheet for editing an account's total balance.
struct EditAccountBalanceSheet: View {
    let account: AccountType
    let currentTotal: Double
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amountValue: Decimal

    // Initialize with the current total for the account.
    init(account: AccountType, currentTotal: Double, onSave: @escaping (Double) -> Void) {
        self.account = account
        self.currentTotal = currentTotal
        self.onSave = onSave
        _amountValue = State(initialValue: Decimal(currentTotal))
    }

    // Sheet UI.
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Spacer()
                Button {
                    dismiss()
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
                Text("Edit \(account.rawValue)")
                    .font(.system(size: 22, weight: .bold))
                Text("Update the total balance for this account")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Total Balance")
                    .font(.system(size: 16, weight: .semibold))
                TextField("0.00", value: $amountValue, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button {
                let newTotal = NSDecimalNumber(decimal: amountValue).doubleValue
                onSave(newTotal)
                dismiss()
            } label: {
                Text("Save")
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

#Preview("Edit Account Balance") {
    EditAccountBalanceSheet(account: .debitCard, currentTotal: 2224.50) { _ in }
        .presentationDetents([.medium])
}
