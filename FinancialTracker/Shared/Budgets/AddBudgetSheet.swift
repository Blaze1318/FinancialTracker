import SwiftUI
import SwiftData

struct AddBudgetSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomAccount.name) private var customAccounts: [CustomAccount]
    @Binding var isPresented: Bool

    private let existingBudget: Budget?
    private let maxDate: Date

    @State private var monthYear: MonthYear
    @State private var accountSelection: AccountSelection
    @State private var categorySelection: BudgetCategorySelection
    @State private var customCategoryName: String
    @State private var amountText: String

    init(
        isPresented: Binding<Bool>,
        maxDate: Date,
        existingBudget: Budget? = nil
    ) {
        _isPresented = isPresented
        self.existingBudget = existingBudget
        self.maxDate = maxDate

        let date = existingBudget?.monthDate ?? Date()
        _monthYear = State(initialValue: MonthYear(date: date))
        _accountSelection = State(initialValue: existingBudget?.accountSelection ?? .system(.debitCard))

        if let budget = existingBudget {
            switch budget.category {
            case .overall:
                _categorySelection = State(initialValue: .overall)
                _customCategoryName = State(initialValue: "")
            case .expense(let category):
                _categorySelection = State(initialValue: .expense(category))
                _customCategoryName = State(initialValue: "")
            case .custom(let name):
                _categorySelection = State(initialValue: .custom)
                _customCategoryName = State(initialValue: name)
            }
            _amountText = State(initialValue: AmountParsing.formattedString(from: budget.limitAmount))
        } else {
            _categorySelection = State(initialValue: .overall)
            _customCategoryName = State(initialValue: "")
            _amountText = State(initialValue: "")
        }
    }

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
                    Text(existingBudget == nil ? "Create Budget" : "Edit Budget")
                        .font(.system(size: 22, weight: .bold))
                    Text("Set a spending limit for a category in a specific month")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                monthPicker

                accountPicker

                categoryPicker

                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Amount")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("$0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    saveBudget()
                } label: {
                    Text(existingBudget == nil ? "Create Budget" : "Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.6)
                .padding(.top, 6)
            }
            .padding(20)
        }
    }

    private var monthPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Month")
                .font(.system(size: 16, weight: .semibold))
            MonthYearPicker(selection: $monthYear, maxDate: maxDate)
        }
    }

    private var accountPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.system(size: 16, weight: .semibold))
            Picker("Account", selection: $accountSelection) {
                ForEach(accountOptions, id: \.selection) { option in
                    Text(option.title).tag(option.selection)
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

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
            Picker("Category", selection: $categorySelection) {
                Text("Overall").tag(BudgetCategorySelection.overall)
                ForEach(SpendingCategory.allCases, id: \.self) { category in
                    Text(category.title).tag(BudgetCategorySelection.expense(category))
                }
                Text("Custom").tag(BudgetCategorySelection.custom)
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if categorySelection == .custom {
                TextField("Custom Category...", text: $customCategoryName)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var accountOptions: [AccountOption] {
        var options = AccountType.allCases.map { account in
            AccountOption(title: account.rawValue, selection: .system(account))
        }
        options.append(contentsOf: customAccounts.map { account in
            AccountOption(title: account.name, selection: .custom(account.id))
        })
        return options
    }

    private func saveBudget() {
        let limit = AmountParsing.parse(amountText)
        guard limit > 0 else { return }
        let category: BudgetCategory = {
            switch categorySelection {
            case .overall:
                return .overall
            case .expense(let category):
                return .expense(category)
            case .custom:
                let trimmed = customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                return .custom(trimmed.isEmpty ? "Custom" : trimmed)
            }
        }()

        let monthDate = monthYear.date
        if let budget = existingBudget {
            budget.monthDate = monthDate
            budget.monthKey = Budget.monthKey(from: monthDate)
            budget.category = category
            budget.accountSelection = accountSelection
            budget.limitAmount = limit
        } else {
            let budget = Budget(
                monthDate: monthDate,
                category: category,
                accountSelection: accountSelection,
                limitAmount: limit
            )
            modelContext.insert(budget)
        }
        try? modelContext.save()
        isPresented = false
    }

    private var canSave: Bool {
        let limit = AmountParsing.parse(amountText)
        return limit > 0
    }
}

private enum BudgetCategorySelection: Hashable {
    case overall
    case expense(SpendingCategory)
    case custom
}

private struct AccountOption: Hashable {
    let title: String
    let selection: AccountSelection
}

private struct MonthYear: Hashable {
    var year: Int
    var month: Int

    init(date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
    }

    var date: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
}

private struct MonthYearPicker: View {
    @Binding var selection: MonthYear
    let maxDate: Date

    var body: some View {
        HStack(spacing: 12) {
            Picker("Month", selection: $selection.month) {
                ForEach(availableMonths, id: \.self) { month in
                    Text(Self.monthSymbols[month - 1]).tag(month)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Picker("Year", selection: $selection.year) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 110, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var availableYears: [Int] {
        let calendar = Calendar.current
        let maxYear = calendar.component(.year, from: maxDate)
        let minYear = maxYear - 1
        return Array(minYear...maxYear + 1)
    }

    private var availableMonths: [Int] {
        let calendar = Calendar.current
        let maxYear = calendar.component(.year, from: maxDate)
        let maxMonth = calendar.component(.month, from: maxDate)
        if selection.year == maxYear {
            return Array(1...maxMonth)
        }
        return Array(1...12)
    }

    private static let monthSymbols = Calendar.current.monthSymbols
}
