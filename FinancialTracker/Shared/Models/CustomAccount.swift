import Foundation
import SwiftData
import SwiftUI

@Model
final class CustomAccount: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = "wallet.pass"
    var colorHex: String = "2B7FFF"
    var baseBalance: Double = 0
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        baseBalance: Double = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.baseBalance = baseBalance
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
