import Foundation
import SwiftData

// SwiftData model for a savings goal.
@Model
final class Goal: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var targetAmount: Double = 0
    var currentAmount: Double = 0
    var deadline: Date?
    var emoji: String = "🎯"
    var colorHex: String = "2B7FFF"

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        deadline: Date? = nil,
        emoji: String,
        colorHex: String
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.emoji = emoji
        self.colorHex = colorHex
    }
}

extension Goal {
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1)
    }
}
