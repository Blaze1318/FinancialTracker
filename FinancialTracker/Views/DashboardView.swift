//
//  DashboardView.swift
//  FinancialTracker
//
//  Created by David Callender on 3/14/26.
//

import SwiftUI
import SwiftData

// Main dashboard screen: summary cards, filters, tabs, and FAB.
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    @Query private var accounts: [Account]
    @Query(sort: \Goal.name) private var goals: [Goal]

    @State private var isAddTransactionPresented = false
    @State private var isAddGoalPresented = false
    @State private var selectedMonth: Date = Date()
    @State private var selectedTab: DashboardTab = .transactions
    @State private var selectedSummary: AccountSummary = .all
    @State private var isMonthPickerPresented = false
    @State private var actionTransaction: TransactionItem?
    @State private var isTransactionActionPresented = false
    @State private var isDeleteConfirmPresented = false
    @State private var transactionToEdit: TransactionItem?
    @State private var accountToEdit: AccountType?
    @State private var goalToEdit: Goal?
    @State private var goalForAddMoney: Goal?
    @State private var celebrationGoalName: String?
    @State private var goalToDelete: Goal?

    // Screen UI.
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Financial Tracker")
                        .font(.title)
                        .fontWeight(.bold)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)

                    Text("Manage your finances with ease")
                        .padding(.horizontal, 10)

                HStack {
                    FinanceSummaryCard(
                        icon: "wallet.pass",
                        title: "All Accounts",
                        amount: summaryTotal(for: .all),
                        gradientStart: AppColors.blue,
                        gradientEnd: AppColors.cyan
                    )
                    .overlay(selectionOverlay(isSelected: selectedSummary == .all, accent: AppColors.cyan))
                    .padding(.horizontal, 8)
                    .onTapGesture { selectedSummary = .all }

                    FinanceSummaryCard(
                        icon: "creditcard",
                        title: "Debit Card",
                        amount: summaryTotal(for: .debitCard),
                        gradientStart: AppColors.green,
                        gradientEnd: AppColors.teal
                    )
                    .overlay(selectionOverlay(isSelected: selectedSummary == .debitCard, accent: AppColors.teal))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            accountToEdit = .debitCard
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.black.opacity(0.25))
                                .clipShape(Circle())
                        }
                        .padding(10)
                    }
                    .padding(.horizontal, 8)
                    .onTapGesture { selectedSummary = .debitCard }
                    .onLongPressGesture { accountToEdit = .debitCard }
                }
                HStack {
                    FinanceSummaryCard(
                        icon: "creditcard",
                        title: "Credit Card",
                        amount: summaryTotal(for: .creditCard),
                        gradientStart: AppColors.pink,
                        gradientEnd: AppColors.coral
                    )
                    .overlay(selectionOverlay(isSelected: selectedSummary == .creditCard, accent: AppColors.coral))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            accountToEdit = .creditCard
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.black.opacity(0.25))
                                .clipShape(Circle())
                        }
                        .padding(10)
                    }
                    .padding(.horizontal, 8)
                    .onTapGesture { selectedSummary = .creditCard }
                    .onLongPressGesture { accountToEdit = .creditCard }

                    FinanceSummaryCard(
                        icon: "dollarsign.circle.fill",
                        title: "Savings",
                        amount: summaryTotal(for: .savings),
                        gradientStart: AppColors.purple,
                        gradientEnd: AppColors.lavender
                    )
                    .overlay(selectionOverlay(isSelected: selectedSummary == .savings, accent: AppColors.lavender))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            accountToEdit = .savings
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.black.opacity(0.25))
                                .clipShape(Circle())
                        }
                        .padding(10)
                    }
                    .padding(.horizontal, 8)
                    .onTapGesture { selectedSummary = .savings }
                    .onLongPressGesture { accountToEdit = .savings }
                }
                FinancialOverviewCard(
                    title: selectedSummary.title,
                    totalAmount: overviewTotals.total,
                    incomeAmount: overviewTotals.income,
                    expensesAmount: overviewTotals.expense,
                    gradientStart: AppColors.blue,
                    gradientEnd: AppColors.cyan
                )
                .padding(.horizontal, 8)

                Button {
                    isMonthPickerPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            Text(Self.monthFormatter.string(from: selectedMonth))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }

                    HStack(spacing: 6) {
                        ForEach(DashboardTab.allCases) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Text(tab.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedTab == tab
                                        ? Color.white
                                        : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 12)

                    Group {
                    switch selectedTab {
                    case .transactions:
                        TransactionsTabView(
                            transactions: filteredTransactions,
                            exportTransactions: transactionsForSummary(selectedSummary),
                            totalCount: filteredTransactions.count,
                            summaryTitle: selectedSummary.title,
                            summaryTotal: summaryTotal(for: selectedSummary),
                            exportFilename: TransactionsCSVBuilder.defaultFilename(summaryTitle: selectedSummary.title),
                            onSelect: { transaction in
                                actionTransaction = transaction
                                isTransactionActionPresented = true
                            }
                        )
                    case .analytics:
                        AnalyticsTabView(
                            spends: analyticsSpends,
                            summary: analyticsSummary,
                            totalForSelectedSummary: summaryTotal(for: selectedSummary)
                        )
                    case .ai:
                        AIInsightsTabView(context: aiInsightContext)
                    case .goals:
                        GoalsTabView(
                            goals: goals,
                            onCreate: { isAddGoalPresented = true },
                            onEdit: { goal in goalToEdit = goal },
                            onDelete: { goal in goalToDelete = goal },
                            onAddMoney: { goal in goalForAddMoney = goal }
                        )
                    }
                }

                    Spacer(minLength: 90)
                }
            }

            FloatingActionButtonView {
                switch selectedTab {
                case .transactions, .analytics:
                    isAddTransactionPresented = true
                case .ai:
                    break
                case .goals:
                    isAddGoalPresented = true
                }
            }
            .frame(width: 56, height: 56)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $isAddTransactionPresented) {
            AddTransactionSheet(isPresented: $isAddTransactionPresented)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $isMonthPickerPresented) {
            MonthPickerSheet(selectedMonth: $selectedMonth, maxDate: Self.maxSelectableDate)
                .presentationDetents([.medium])
        }
        .sheet(item: $transactionToEdit) { transaction in
            AddTransactionSheet(
                isPresented: Binding(
                    get: { transactionToEdit != nil },
                    set: { if !$0 { transactionToEdit = nil } }
                ),
                existingTransaction: transaction
            )
            .presentationDetents([.large])
        }
        .sheet(item: $accountToEdit) { account in
                if let accountModel = accountForType(account) {
                    EditAccountBalanceSheet(
                        account: account,
                        currentTotal: summaryTotal(for: AccountSummary(account: account)),
                        onSave: { newTotal in
                            let net = netTransactionTotal(for: account)
                            accountModel.baseBalance = newTotal - net
                            try? modelContext.save()
                        }
                    )
                    .presentationDetents([.medium])
                }
            }
        .sheet(isPresented: $isAddGoalPresented) {
            AddGoalSheet(isPresented: $isAddGoalPresented)
                .presentationDetents([.large])
        }
        .sheet(item: $goalToEdit) { goal in
            AddGoalSheet(
                isPresented: Binding(
                    get: { goalToEdit != nil },
                    set: { if !$0 { goalToEdit = nil } }
                ),
                existingGoal: goal
            )
            .presentationDetents([.large])
        }
        .sheet(item: $goalForAddMoney) { goal in
            AddMoneySheet(
                isPresented: Binding(
                    get: { goalForAddMoney != nil },
                    set: { if !$0 { goalForAddMoney = nil } }
                ),
                goal: goal,
                onGoalCompleted: {
                    celebrationGoalName = goal.name
                }
            )
            .presentationDetents([.medium])
        }
        .confirmationDialog(
            "Transaction Options",
            isPresented: $isTransactionActionPresented,
            titleVisibility: .visible
        ) {
            Button("Edit") {
                if let transaction = actionTransaction {
                    transactionToEdit = transaction
                }
            }
            Button("Delete", role: .destructive) {
                isDeleteConfirmPresented = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Transaction?", isPresented: $isDeleteConfirmPresented) {
            Button("Delete", role: .destructive) {
                guard let transaction = actionTransaction else { return }
                modelContext.delete(transaction)
                try? modelContext.save()
                actionTransaction = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Goal Reached!", isPresented: Binding(
            get: { celebrationGoalName != nil },
            set: { if !$0 { celebrationGoalName = nil } }
        )) {
            Button("Nice!", role: .cancel) {}
        } message: {
            Text("\(celebrationGoalName ?? "Your goal") is complete. Great work!")
        }
        .alert("Delete Goal?", isPresented: Binding(
            get: { goalToDelete != nil },
            set: { if !$0 { goalToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let goal = goalToDelete {
                    modelContext.delete(goal)
                    try? modelContext.save()
                }
                goalToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                goalToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .task {
            SeedData.seedIfNeeded(context: modelContext)
        }
    }
}

private extension DashboardView {
    // Month label formatter for the dashboard filter.
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    // Maximum selectable date (end of current month).
    static var maxSelectableDate: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components) ?? Date()
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? Date()
    }

    // Transactions filtered by month and selected account.
    var filteredTransactions: [TransactionItem] {
        let monthFiltered = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }
        switch selectedSummary {
        case .all:
            return monthFiltered
        case .debitCard:
            return monthFiltered.filter { $0.account == .debitCard }
        case .creditCard:
            return monthFiltered.filter { $0.account == .creditCard }
        case .savings:
            return monthFiltered.filter { $0.account == .savings }
        }
    }

    // Summary total for the top account cards.
    func summaryTotal(for summary: AccountSummary) -> Double {
        let scoped = transactionsForSummary(summary)
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        let net = income - expense
        switch summary {
        case .all:
            return accountTotal(.debitCard) + accountTotal(.creditCard) + accountTotal(.savings)
        case .debitCard:
            return accountBaseBalance(for: .debitCard) + net
        case .creditCard:
            return accountBaseBalance(for: .creditCard) + net
        case .savings:
            return accountBaseBalance(for: .savings) + net
        }
    }

    // Totals for the overview card (income/expense and overall).
    var overviewTotals: (total: Double, income: Double, expense: Double) {
        let scoped = transactionsForSummary(selectedSummary)
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        let net = income - expense
        switch selectedSummary {
        case .all:
            let total = accountTotal(.debitCard) + accountTotal(.creditCard) + accountTotal(.savings)
            return (total, income, expense)
        case .debitCard:
            return (accountBaseBalance(for: .debitCard) + net, income, expense)
        case .creditCard:
            return (accountBaseBalance(for: .creditCard) + net, income, expense)
        case .savings:
            return (accountBaseBalance(for: .savings) + net, income, expense)
        }
    }

    // Transaction subset by account summary.
    func transactionsForSummary(_ summary: AccountSummary) -> [TransactionItem] {
        switch summary {
        case .all:
            return transactions
        case .debitCard:
            return transactions.filter { $0.account == .debitCard }
        case .creditCard:
            return transactions.filter { $0.account == .creditCard }
        case .savings:
            return transactions.filter { $0.account == .savings }
        }
    }

    // Net total (income - expenses) for a single account.
    func netTransactionTotal(for account: AccountType) -> Double {
        let scoped = transactions.filter { $0.account == account }
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        return income - expense
    }

    // Account total = base balance + net transactions.
    func accountTotal(_ account: AccountType) -> Double {
        accountBaseBalance(for: account) + netTransactionTotal(for: account)
    }

    // Base balance lookup from persisted accounts.
    func accountBaseBalance(for account: AccountType) -> Double {
        accounts.first(where: { $0.type == account })?.baseBalance ?? 0
    }

    // Ensure we can always resolve an account model for editing.
    func accountForType(_ account: AccountType) -> Account? {
        if let existing = accounts.first(where: { $0.type == account }) {
            return existing
        }
        let created = Account(type: account, baseBalance: 0)
        modelContext.insert(created)
        return created
    }

    // Selected-card highlight overlay.
    @ViewBuilder
    func selectionOverlay(isSelected: Bool, accent: Color) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accent.opacity(0.9), lineWidth: 2)
                .shadow(color: accent.opacity(0.35), radius: 8, x: 0, y: 3)
        }
    }

    // Aggregate expense totals per category for analytics.
    var analyticsSpends: [CategorySpend] {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        var totals: [String: (amount: Double, color: Color)] = [:]
        for transaction in expenses {
            switch transaction.category {
            case .expense(let category):
                let key = category.title
                let entry = totals[key] ?? (0, category.accentColor)
                totals[key] = (entry.amount + transaction.amount, entry.color)
            case .custom(let name):
                let key = name.isEmpty ? "Custom" : name
                let entry = totals[key] ?? (0, AppColors.blue)
                totals[key] = (entry.amount + transaction.amount, entry.color)
            default:
                continue
            }
        }
        return totals
            .map { CategorySpend(title: $0.key, amount: $0.value.amount, color: $0.value.color) }
            .sorted { $0.amount > $1.amount }
    }

    // Analytics summary numbers (income/expenses/net).
    var analyticsSummary: (income: Double, expenses: Double, net: Double) {
        let scoped = transactionsForSummary(selectedSummary)
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        let net = analyticsNetBalance
        return (income, expense, net)
    }

    // Net balance used in analytics summary (includes base balances).
    var analyticsNetBalance: Double {
        switch selectedSummary {
        case .all:
            return accountTotal(.debitCard) + accountTotal(.creditCard) + accountTotal(.savings)
        case .debitCard:
            return accountTotal(.debitCard)
        case .creditCard:
            return accountTotal(.creditCard)
        case .savings:
            return accountTotal(.savings)
        }
    }

    // Context passed into Apple Intelligence generation.
    var aiInsightContext: AIInsightsContext {
        let current = filteredTransactions
        let previous = transactionsForMonth(previousMonth(from: selectedMonth), summary: selectedSummary)

        let income = current.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = current.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        let net = income - expense
        let previousExpense = previous.filter { $0.type == .expense }.map(\.amount).reduce(0, +)

        let snapshots = current.map { transaction in
            TransactionSnapshot(
                title: transaction.title,
                category: transaction.category.title,
                type: transaction.type.rawValue,
                amount: transaction.amount,
                dateISO: Self.isoFormatter.string(from: transaction.date)
            )
        }

        let previousSnapshots = previous.map { transaction in
            TransactionSnapshot(
                title: transaction.title,
                category: transaction.category.title,
                type: transaction.type.rawValue,
                amount: transaction.amount,
                dateISO: Self.isoFormatter.string(from: transaction.date)
            )
        }

        return AIInsightsContext(
            month: selectedMonth,
            current: snapshots,
            previous: previousSnapshots,
            totals: MonthlyTotals(
                income: income,
                expense: expense,
                net: net,
                previousExpense: previousExpense
            )
        )
    }

    private func previousMonth(from date: Date) -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }

    private func transactionsForMonth(_ month: Date, summary: AccountSummary) -> [TransactionItem] {
        transactionsForSummary(summary).filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: month, toGranularity: .month)
        }
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private enum DashboardTab: String, CaseIterable, Identifiable {
    case transactions
    case analytics
    case ai
    case goals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .transactions:
            return "Transactions"
        case .analytics:
            return "Analytics"
        case .ai:
            return "AI"
        case .goals:
            return "Goals"
        }
    }
}

private enum AccountSummary {
    case all
    case debitCard
    case creditCard
    case savings

    var title: String {
        switch self {
        case .all:
            return "All Accounts"
        case .debitCard:
            return "Debit Card"
        case .creditCard:
            return "Credit Card"
        case .savings:
            return "Savings"
        }
    }
}

private extension AccountSummary {
    init(account: AccountType) {
        switch account {
        case .debitCard:
            self = .debitCard
        case .creditCard:
            self = .creditCard
        case .savings:
            self = .savings
        }
    }
}

// Moved tab content to AnalyticsTabView and TransactionsTabView.

#Preview {
    DashboardView()
        .modelContainer(for: [Account.self, TransactionItem.self], inMemory: true)
}
