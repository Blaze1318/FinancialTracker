import SwiftUI
import SwiftData

// Sheet for creating or editing a transaction.
struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var transactionType: TransactionType = .expense
    @State private var account: AccountType = .debitCard
    @State private var expenseCategory: SpendingCategory = .foodAndDining
    @State private var incomeCategory: IncomeCategory = .salary
    @State private var amountValue: Decimal = 0
    @State private var descriptionText: String = ""
    private let existingTransaction: TransactionItem?

    // Initialize for create or edit flows.
    init(
        isPresented: Binding<Bool>,
        existingTransaction: TransactionItem? = nil
    ) {
        _isPresented = isPresented
        _transactionType = State(initialValue: existingTransaction?.type ?? .expense)
        _account = State(initialValue: existingTransaction?.account ?? .debitCard)
        switch existingTransaction?.category {
        case .expense(let category):
            _expenseCategory = State(initialValue: category)
            _incomeCategory = State(initialValue: .salary)
        case .income(let category):
            _expenseCategory = State(initialValue: .foodAndDining)
            _incomeCategory = State(initialValue: category)
        case .none:
            _expenseCategory = State(initialValue: .foodAndDining)
            _incomeCategory = State(initialValue: .salary)
        }
        _amountValue = State(initialValue: Decimal(existingTransaction?.amount ?? 0))
        _descriptionText = State(initialValue: existingTransaction?.subtitle ?? "")
        self.existingTransaction = existingTransaction
    }

    // Sheet UI.
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
                Text(isEditing ? "Edit Transaction" : "Add Transaction")
                    .font(.system(size: 22, weight: .bold))
                Text(isEditing ? "Update the transaction details" : "Record a new income or expense transaction")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    transactionType = .expense
                } label: {
                    Text("Expense")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(transactionType == .expense ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            transactionType == .expense
                            ? TransactionType.expense.amountColor
                            : Color.black.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    transactionType = .income
                } label: {
                    Text("Income")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(transactionType == .income ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            transactionType == .income
                            ? TransactionType.income.amountColor
                            : Color.black.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.top, 6)

            VStack(alignment: .leading, spacing: 8) {
                Text("Account")
                    .font(.system(size: 16, weight: .semibold))
                Picker("Account", selection: $account) {
                    ForEach(AccountType.allCases) { account in
                        Text(account.rawValue).tag(account)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.system(size: 16, weight: .semibold))
                TextField("0.00", value: $amountValue, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.system(size: 16, weight: .semibold))
                if transactionType == .expense {
                    Picker("Category", selection: $expenseCategory) {
                        ForEach(SpendingCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Picker("Category", selection: $incomeCategory) {
                        ForEach(IncomeCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.system(size: 16, weight: .semibold))
                TextField("What was this for?", text: $descriptionText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Button {
                guard let amount = parsedAmount else { return }
                let subtitle = descriptionText.isEmpty ? "No description" : descriptionText
                let category: TransactionCategory = {
                    switch transactionType {
                    case .expense:
                        return .expense(expenseCategory)
                    case .income:
                        return .income(incomeCategory)
                    }
                }()
                if let transaction = existingTransaction {
                    transaction.title = category.title
                    transaction.subtitle = subtitle
                    transaction.amount = amount
                    transaction.type = transactionType
                    transaction.account = account
                    transaction.category = category
                } else {
                    let transaction = TransactionItem(
                        title: category.title,
                        subtitle: subtitle,
                        date: Date(),
                        amount: amount,
                        type: transactionType,
                        account: account,
                        category: category
                    )
                    modelContext.insert(transaction)
                }
                try? modelContext.save()
                isPresented = false
            } label: {
                Text(isEditing ? "Save Changes" : "Add Transaction")
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

    // Convert the bound decimal value into a Double.
    private var parsedAmount: Double? {
        NSDecimalNumber(decimal: amountValue).doubleValue
    }

    // Whether this sheet is editing an existing transaction.
    private var isEditing: Bool {
        existingTransaction != nil
    }
}

#Preview("Add Transaction Sheet") {
    AddTransactionSheet(isPresented: .constant(true))
        .presentationDetents([.medium, .large])
        .modelContainer(for: [Account.self, TransactionItem.self], inMemory: true)
}
