import SwiftUI
import SwiftData

// Sheet for creating or editing a transaction.
struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var transactionType: TransactionType = .expense
    @State private var account: AccountType = .debitCard
    @State private var expenseSelection: ExpenseCategorySelection = .predefined(.foodAndDining)
    @State private var incomeSelection: IncomeCategorySelection = .predefined(.salary)
    @State private var amountText: String = ""
    @State private var descriptionText: String = ""
    @State private var transactionDate: Date = Date()
    @State private var customCategoryName: String = ""
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
            _expenseSelection = State(initialValue: .predefined(category))
            _incomeSelection = State(initialValue: .predefined(.salary))
        case .income(let category):
            _expenseSelection = State(initialValue: .predefined(.foodAndDining))
            _incomeSelection = State(initialValue: .predefined(category))
        case .custom(let name):
            if existingTransaction?.type == .income {
                _incomeSelection = State(initialValue: .custom)
                _expenseSelection = State(initialValue: .predefined(.foodAndDining))
            } else {
                _expenseSelection = State(initialValue: .custom)
                _incomeSelection = State(initialValue: .predefined(.salary))
            }
            _customCategoryName = State(initialValue: name)
        case .none:
            _expenseSelection = State(initialValue: .predefined(.foodAndDining))
            _incomeSelection = State(initialValue: .predefined(.salary))
        }
        if let amount = existingTransaction?.amount, amount > 0 {
            _amountText = State(initialValue: AmountParsing.formattedString(from: amount))
        } else {
            _amountText = State(initialValue: "")
        }
        _descriptionText = State(initialValue: existingTransaction?.subtitle ?? "")
        if let date = existingTransaction?.date, date <= Date() {
            _transactionDate = State(initialValue: date)
        } else {
            _transactionDate = State(initialValue: Date())
        }
        self.existingTransaction = existingTransaction
    }

    // Sheet UI.
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                TextField("$0.00", text: $amountText)
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
                    Picker("Category", selection: $expenseSelection) {
                        ForEach(SpendingCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(ExpenseCategorySelection.predefined(category))
                        }
                        Text("Custom").tag(ExpenseCategorySelection.custom)
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if expenseSelection == .custom {
                        TextField("Custom Category...", text: $customCategoryName)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                } else {
                    Picker("Category", selection: $incomeSelection) {
                        ForEach(IncomeCategory.allCases, id: \.self) { category in
                            Text(category.title).tag(IncomeCategorySelection.predefined(category))
                        }
                        Text("Custom").tag(IncomeCategorySelection.custom)
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if incomeSelection == .custom {
                        TextField("Custom Category...", text: $customCategoryName)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.system(size: 16, weight: .semibold))
                DatePicker(
                    "Transaction Date",
                    selection: $transactionDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
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
                let amount = parsedAmount
                guard amount > 0 else { return }
                let subtitle = descriptionText.isEmpty ? "No description" : descriptionText
                let trimmedCustom = customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                let customValue = trimmedCustom.isEmpty ? "Custom" : trimmedCustom
                let category: TransactionCategory = {
                    switch transactionType {
                    case .expense:
                        switch expenseSelection {
                        case .predefined(let category):
                            return .expense(category)
                        case .custom:
                            return .custom(customValue)
                        }
                    case .income:
                        switch incomeSelection {
                        case .predefined(let category):
                            return .income(category)
                        case .custom:
                            return .custom(customValue)
                        }
                    }
                }()
                if let transaction = existingTransaction {
                    transaction.title = category.title
                    transaction.subtitle = subtitle
                    transaction.amount = amount
                    transaction.type = transactionType
                    transaction.account = account
                    transaction.category = category
                    transaction.date = transactionDate
                } else {
                    let transaction = TransactionItem(
                        title: category.title,
                        subtitle: subtitle,
                        date: transactionDate,
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
    }

    // Convert the bound decimal value into a Double.
    private var parsedAmount: Double {
        AmountParsing.parse(amountText)
    }

    // Whether this sheet is editing an existing transaction.
    private var isEditing: Bool {
        existingTransaction != nil
    }
}

private enum ExpenseCategorySelection: Hashable {
    case predefined(SpendingCategory)
    case custom
}

private enum IncomeCategorySelection: Hashable {
    case predefined(IncomeCategory)
    case custom
}


#Preview("Add Transaction Sheet") {
    AddTransactionSheet(isPresented: .constant(true))
        .presentationDetents([.medium, .large])
        .modelContainer(for: [Account.self, TransactionItem.self], inMemory: true)
}
