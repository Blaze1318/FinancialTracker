import SwiftUI
import UIKit

// UIKit text field wrapper for currency entry (currently unused).
struct CurrencyAmountField: UIViewRepresentable {
    @Binding var rawText: String

    // Build the underlying UITextField.
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.textAlignment = .left
        textField.delegate = context.coordinator
        textField.textColor = .label
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.placeholder = "$ 0.00"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return textField
    }

    // Keep the displayed text formatted.
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = formattedValue
    }

    // Provide coordinator for input filtering.
    func makeCoordinator() -> Coordinator {
        Coordinator(rawText: $rawText)
    }

    private var formattedValue: String {
        let sanitized = rawText.replacingOccurrences(of: localeDecimalSeparator, with: ".")
        guard let value = Double(sanitized), !rawText.isEmpty else { return "" }
        return Self.currencyFormatter.string(from: NSNumber(value: value)) ?? ""
    }

    private var localeDecimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var rawText: String

        private var decimalSeparator: String {
            Locale.current.decimalSeparator ?? "."
        }

        init(rawText: Binding<String>) {
            _rawText = rawText
        }

        // Filter input to digits and one decimal separator.
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let current = rawText as NSString
            let updated = current.replacingCharacters(in: range, with: string)
            let allowed = updated.filter { $0.isNumber || String($0) == decimalSeparator }
            let separatorCount = allowed.filter { String($0) == decimalSeparator }.count
            guard separatorCount <= 1 else { return false }
            rawText = allowed

            let sanitized = allowed.replacingOccurrences(of: decimalSeparator, with: ".")
            if let value = Double(sanitized), !allowed.isEmpty {
                textField.text = CurrencyAmountField.currencyFormatter.string(from: NSNumber(value: value)) ?? ""
            } else {
                textField.text = ""
            }
            return false
        }
    }
}

private extension CurrencyAmountField {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
