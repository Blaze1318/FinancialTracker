//
//  ContentView.swift
//  FinancialTracker
//
//  Created by David Callender on 3/14/26.
//

import SwiftUI
import SwiftData

// App entry point view.
struct ContentView: View {
    // Root view.
    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Account.self, CustomAccount.self, TransactionItem.self, Goal.self, Budget.self], inMemory: true)
}
