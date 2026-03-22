# FinancialTracker

SwiftUI finance dashboard prototype with editable accounts, transaction management, and analytics views.

## Overview
- Dashboard with account summary cards, overview totals, month filter, tab switcher, and FAB.
- Transactions tab with editable/deletable transaction list.
- Analytics tab with category breakdowns and summary totals.

## Structure
- `FinancialTracker/Views`
  - `DashboardView.swift` is the main screen.
  - `TransactionsTabView.swift` and `AnalyticsTabView.swift` render tab content.
- `FinancialTracker/Shared`
  - Reusable cards, enums, and sheets for transactions, analytics, and account edits.

## Editing
- Tap a transaction to edit or delete.
- Long-press Debit/Credit/Savings cards to edit account totals.
- Add transactions via the floating action button.

## Notes
- Analytics is view-only and reflects the selected account and month filter.
