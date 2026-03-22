import SwiftUI

// Centralized brand palette used across the app.
extension Color {
    // Initialize a SwiftUI Color from a hex string (RGB or ARGB).
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// App color tokens for gradients, accents, and highlights.
enum AppColors {
    static let blue = Color(hex: "2B7FFF")
    static let cyan = Color(hex: "00D3F3")
    static let green = Color(hex: "00BC7D")
    static let teal = Color(hex: "00D5BE")
    static let pink = Color(hex: "F6339A")
    static let coral = Color(hex: "FF637E")
    static let purple = Color(hex: "AD46FF")
    static let lavender = Color(hex: "A684FF")
}
