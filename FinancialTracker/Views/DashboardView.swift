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
    @AppStorage("whats_new_seen_v1_2_0") private var whatsNewSeen = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    @Query private var accounts: [Account]
    @Query(sort: \CustomAccount.name) private var customAccounts: [CustomAccount]
    @Query(sort: \Goal.name) private var goals: [Goal]
    @Query(sort: \Budget.createdAt) private var budgets: [Budget]

    @State private var isAddTransactionPresented = false
    @State private var isAddGoalPresented = false
    @State private var selectedMonth: Date = Date()
    @State private var selectedTab: DashboardTab = .activity
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
    @State private var isAddCustomAccountPresented = false
    @State private var customAccountToEdit: CustomAccount?
    @State private var customAccountToDelete: CustomAccount?
    @State private var isAddBudgetPresented = false
    @State private var budgetToEdit: Budget?
    @State private var budgetToDelete: Budget?
    @State private var isWhatsNewPresented = false
    private let accountGridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // Screen UI.
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Financial Tracker")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            isWhatsNewPresented = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("What's New")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Capsule())
                            .overlay(
                                Group {
                                    if !whatsNewSeen {
                                        Circle()
                                            .fill(AppColors.blue)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 38, y: -10)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)

                    Text("Manage your finances with ease")
                        .padding(.horizontal, 10)

                LazyVGrid(columns: accountGridColumns, spacing: 12) {
                    ForEach(accountSummaries, id: \.id) { summary in
                        FinanceSummaryCard(
                            icon: summary.iconName(customAccountsById: customAccountsById),
                            iconIsAsset: summary.iconIsAsset(customAccountsById: customAccountsById),
                            title: summary.title(customAccountsById: customAccountsById),
                            amount: summaryTotal(for: summary),
                            gradientStart: summary.gradientStart(customAccountsById: customAccountsById),
                            gradientEnd: summary.gradientEnd(customAccountsById: customAccountsById)
                        )
                        .overlay(
                            selectionOverlay(
                                isSelected: selectedSummary == summary,
                                accent: summary.accent(customAccountsById: customAccountsById)
                            )
                        )
                        .overlay(alignment: .topTrailing) {
                            summaryActionButton(for: summary)
                        }
                        .onTapGesture { selectedSummary = summary }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

                Button {
                    isAddCustomAccountPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Add New Account")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .background(Color.white.opacity(0.6))
                    )
                }
                .padding(.horizontal, 12)
                FinancialOverviewCard(
                    title: selectedSummary.title(customAccountsById: customAccountsById),
                    totalAmount: overviewTotals.total,
                    incomeAmount: overviewTotals.income,
                    expensesAmount: overviewTotals.expense,
                    gradientStart: AppColors.blue,
                    gradientEnd: AppColors.cyan
                )
                .padding(.horizontal, 12)

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
                .padding(.horizontal, 12)

                    HStack(spacing: 6) {
                        ForEach(DashboardTab.allCases) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: tab.iconName)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(tab.title)
                                        .font(.system(size: 13, weight: .semibold))
                                }
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
                    case .activity:
                        TransactionsTabView(
                            transactions: filteredTransactions,
                            exportTransactions: filteredTransactions,
                            totalCount: filteredTransactions.count,
                            summaryTitle: selectedSummary.title(customAccountsById: customAccountsById),
                            summaryTotal: filteredMonthNet,
                            exportFilename: TransactionsCSVBuilder.defaultFilename(
                                summaryTitle: selectedSummary.title(customAccountsById: customAccountsById)
                            ),
                            customAccountsById: customAccountsById,
                            onSelect: { transaction in
                                actionTransaction = transaction
                                isTransactionActionPresented = true
                            }
                        )
                    case .charts:
                        AnalyticsTabView(
                            spends: analyticsSpends,
                            summary: analyticsSummary,
                            totalForSelectedSummary: summaryTotal(for: selectedSummary)
                        )
                    case .budget:
                        BudgetTabView(
                            budgets: budgets,
                            transactions: transactions,
                            selectedMonth: selectedMonth,
                            selectedSummary: selectedSummary,
                            customAccountsById: customAccountsById,
                            onCreate: { isAddBudgetPresented = true },
                            onEdit: { budget in budgetToEdit = budget },
                            onDelete: { budget in budgetToDelete = budget }
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
                case .activity, .charts:
                    isAddTransactionPresented = true
                case .budget:
                    isAddBudgetPresented = true
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
        .sheet(isPresented: $isWhatsNewPresented) {
            WhatsNewSheet(isPresented: $isWhatsNewPresented)
                .presentationDetents([.large])
        }
        .onChange(of: isWhatsNewPresented) { _, isPresented in
            if !isPresented {
                whatsNewSeen = true
            }
        }
        .sheet(isPresented: $isAddBudgetPresented) {
            AddBudgetSheet(
                isPresented: $isAddBudgetPresented,
                maxDate: Self.maxSelectableDate
            )
            .presentationDetents([.large])
        }
        .sheet(item: $budgetToEdit) { budget in
            AddBudgetSheet(
                isPresented: Binding(
                    get: { budgetToEdit != nil },
                    set: { if !$0 { budgetToEdit = nil } }
                ),
                maxDate: Self.maxSelectableDate,
                existingBudget: budget
            )
            .presentationDetents([.large])
        }
        .sheet(item: $accountToEdit) { account in
                if let accountModel = accountForType(account) {
                    EditAccountBalanceSheet(
                        account: account,
                        currentTotal: summaryTotal(for: .system(account)),
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
        .sheet(isPresented: $isAddCustomAccountPresented) {
            AddCustomAccountSheet(isPresented: $isAddCustomAccountPresented)
                .presentationDetents([.large])
        }
        .sheet(item: $customAccountToEdit) { account in
            AddCustomAccountSheet(
                isPresented: Binding(
                    get: { customAccountToEdit != nil },
                    set: { if !$0 { customAccountToEdit = nil } }
                ),
                existingAccount: account
            )
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
        .alert("Delete Account?", isPresented: Binding(
            get: { customAccountToDelete != nil },
            set: { if !$0 { customAccountToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                guard let account = customAccountToDelete else { return }
                deleteCustomAccount(account)
                customAccountToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                customAccountToDelete = nil
            }
        } message: {
            Text("All transactions under this account will be deleted.")
        }
        .alert("Delete Budget?", isPresented: Binding(
            get: { budgetToDelete != nil },
            set: { if !$0 { budgetToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let budget = budgetToDelete {
                    modelContext.delete(budget)
                    try? modelContext.save()
                }
                budgetToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                budgetToDelete = nil
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
        case .system(let account):
            return monthFiltered.filter { $0.accountSelection == .system(account) }
        case .custom(let id):
            return monthFiltered.filter { $0.accountSelection == .custom(id) }
        }
    }

    var filteredMonthNet: Double {
        let income = filteredTransactions.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = filteredTransactions.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        return income - expense
    }

    var customAccountsById: [UUID: CustomAccount] {
        Dictionary(uniqueKeysWithValues: customAccounts.map { ($0.id, $0) })
    }

    var accountSummaries: [AccountSummary] {
        var summaries: [AccountSummary] = [
            .all,
            .system(.debitCard),
            .system(.creditCard),
            .system(.savings)
        ]
        summaries.append(contentsOf: customAccounts.map { .custom($0.id) })
        return summaries
    }

    // Summary total for the top account cards.
    func summaryTotal(for summary: AccountSummary) -> Double {
        switch summary {
        case .all:
            let systemTotal = accountTotal(.debitCard) + accountTotal(.creditCard) + accountTotal(.savings)
            let customTotal = customAccounts.reduce(0) { total, account in
                total + customAccountTotal(account.id)
            }
            return systemTotal + customTotal
        case .system(let account):
            let scoped = transactionsForSummary(summary)
            let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
            let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
            let net = income - expense
            return accountBaseBalance(for: account) + net
        case .custom(let id):
            return customAccountTotal(id)
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
            let total = summaryTotal(for: .all)
            return (total, income, expense)
        case .system(let account):
            return (accountBaseBalance(for: account) + net, income, expense)
        case .custom(let id):
            return (customAccountTotal(id), income, expense)
        }
    }

    // Transaction subset by account summary.
    func transactionsForSummary(_ summary: AccountSummary) -> [TransactionItem] {
        switch summary {
        case .all:
            return transactions
        case .system(let account):
            return transactions.filter { $0.accountSelection == .system(account) }
        case .custom(let id):
            return transactions.filter { $0.accountSelection == .custom(id) }
        }
    }

    // Net total (income - expenses) for a single account.
    func netTransactionTotal(for account: AccountType) -> Double {
        let scoped = transactions.filter { $0.accountSelection == .system(account) }
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        return income - expense
    }

    func customAccountTotal(_ id: UUID) -> Double {
        let scoped = transactions.filter { $0.accountSelection == .custom(id) }
        let income = scoped.filter { $0.type == .income }.map(\.amount).reduce(0, +)
        let expense = scoped.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
        let base = customAccountsById[id]?.baseBalance ?? 0
        return base + (income - expense)
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

    func deleteCustomAccount(_ account: CustomAccount) {
        let id = account.id
        let related = transactions.filter { $0.accountSelection == .custom(id) }
        for transaction in related {
            modelContext.delete(transaction)
        }
        let relatedBudgets = budgets.filter { $0.accountSelection == .custom(id) }
        for budget in relatedBudgets {
            modelContext.delete(budget)
        }
        modelContext.delete(account)
        if selectedSummary == .custom(id) {
            selectedSummary = .all
        }
        try? modelContext.save()
    }

    @ViewBuilder
    func summaryActionButton(for summary: AccountSummary) -> some View {
        switch summary {
        case .system(let account):
            Button {
                accountToEdit = account
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.black.opacity(0.25))
                    .clipShape(Circle())
            }
            .padding(10)
        case .custom(let id):
            if let account = customAccountsById[id] {
                Menu {
                    Button("Edit") {
                        customAccountToEdit = account
                    }
                    Button("Delete", role: .destructive) {
                        customAccountToDelete = account
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.black.opacity(0.25))
                        .clipShape(Circle())
                }
                .padding(10)
            }
        case .all:
            EmptyView()
        }
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
            return summaryTotal(for: .all)
        case .system(let account):
            return accountTotal(account)
        case .custom(let id):
            return customAccountTotal(id)
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
    case activity
    case charts
    case budget
    case ai
    case goals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .activity:
            return "Activity"
        case .charts:
            return "Charts"
        case .budget:
            return "Budget"
        case .ai:
            return "AI"
        case .goals:
            return "Goals"
        }
    }

    var iconName: String {
        switch self {
        case .activity:
            return "waveform.path.ecg"
        case .charts:
            return "chart.pie"
        case .budget:
            return "wallet.pass"
        case .ai:
            return "sparkles"
        case .goals:
            return "target"
        }
    }
}


// Moved tab content to AnalyticsTabView and TransactionsTabView.

#Preview {
    DashboardView()
        .modelContainer(for: [Account.self, CustomAccount.self, TransactionItem.self, Budget.self], inMemory: true)
}
