import Foundation

enum AmountParsing {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func formattedString(from value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? ""
    }

    static func parse(_ text: String) -> Double {
        let filtered = text.filter { "0123456789.".contains($0) }
        return Double(filtered) ?? 0
    }
}
