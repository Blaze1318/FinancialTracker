//
//  FinancialTrackerApp.swift
//  FinancialTracker
//
//  Created by David Callender on 3/14/26.
//

import SwiftUI
import SwiftData

@main
struct FinancialTrackerApp: App {
    private let modelContainer: ModelContainer
    init() {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.tracker.FinancialTracker"
        let cloudContainerId = "iCloud.\(bundleId)"
        let schema = Schema([Account.self, CustomAccount.self, TransactionItem.self, Goal.self, Budget.self])

        do {
            let cloudConfig = ModelConfiguration(
                "CloudV2",
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .none,
                cloudKitDatabase: .private(cloudContainerId)
            )
            self.modelContainer = try ModelContainer(
                for: Account.self,
                CustomAccount.self,
                TransactionItem.self,
                Goal.self,
                Budget.self,
                configurations: cloudConfig
            )
        } catch {
            do {
                let fallbackConfig = ModelConfiguration(
                    "Default",
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
                self.modelContainer = try ModelContainer(
                for: Account.self,
                CustomAccount.self,
                TransactionItem.self,
                Goal.self,
                Budget.self,
                configurations: fallbackConfig
            )
            } catch {
                fatalError("Failed to initialize SwiftData container: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(modelContainer)
    }
}
