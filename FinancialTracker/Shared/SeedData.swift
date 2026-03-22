import Foundation
import SwiftData

// Seed initial accounts on first launch.
enum SeedData {
    static func seedIfNeeded(context: ModelContext) {
        let accountCount = (try? context.fetchCount(FetchDescriptor<Account>())) ?? 0
        if accountCount == 0 {
            context.insert(Account(type: .debitCard, baseBalance: 0))
            context.insert(Account(type: .creditCard, baseBalance: 0))
            context.insert(Account(type: .savings, baseBalance: 0))
        }
    }
}
