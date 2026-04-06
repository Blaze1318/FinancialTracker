import SwiftUI
import SwiftData

struct AddCustomAccountSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    private let existingAccount: CustomAccount?

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String
    @State private var startingBalanceText: String

    init(isPresented: Binding<Bool>, existingAccount: CustomAccount? = nil) {
        _isPresented = isPresented
        self.existingAccount = existingAccount
        _name = State(initialValue: existingAccount?.name ?? "")
        _selectedIcon = State(initialValue: existingAccount?.iconName ?? Self.iconOptions.first?.symbol ?? "wallet.pass")
        _selectedColorHex = State(initialValue: existingAccount?.colorHex ?? Self.colorOptions.first?.hex ?? "2B7FFF")
        if let balance = existingAccount?.baseBalance, balance != 0 {
            _startingBalanceText = State(initialValue: AmountParsing.formattedString(from: balance))
        } else {
            _startingBalanceText = State(initialValue: "")
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }

                VStack(spacing: 6) {
                    Text(existingAccount == nil ? "Add New Account" : "Edit Account")
                        .font(.system(size: 22, weight: .bold))
                    Text("Create a custom account to track your finances")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Name")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("e.g., Investment Account, Cash Wallet", text: $name)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                iconPicker
                colorPicker

                VStack(alignment: .leading, spacing: 8) {
                    Text("Starting Balance")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("$0.00", text: $startingBalanceText)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    saveAccount()
                } label: {
                    Text(existingAccount == nil ? "Add Account" : "Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.6)
                .padding(.top, 6)
            }
            .padding(20)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Icon")
                .font(.system(size: 16, weight: .semibold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(Self.iconOptions, id: \.symbol) { option in
                    Button {
                        selectedIcon = option.symbol
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 22, weight: .semibold))
                            Text(option.label)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedIcon == option.symbol ? AppColors.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Color")
                .font(.system(size: 16, weight: .semibold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(Self.colorOptions) { option in
                    Button {
                        selectedColorHex = option.hex
                    } label: {
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(option.color)
                                .frame(height: 36)
                            Text(option.label)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedColorHex == option.hex ? AppColors.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    private func saveAccount() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let balance = AmountParsing.parse(startingBalanceText)
        if let account = existingAccount {
            account.name = trimmed
            account.iconName = selectedIcon
            account.colorHex = selectedColorHex
            account.baseBalance = balance
        } else {
            let account = CustomAccount(
                name: trimmed,
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                baseBalance: balance
            )
            modelContext.insert(account)
        }
        try? modelContext.save()
        isPresented = false
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private extension AddCustomAccountSheet {
    struct IconOption {
        let symbol: String
        let label: String
    }

    struct ColorOption: Identifiable {
        let id = UUID()
        let label: String
        let hex: String
        var color: Color { Color(hex: hex) }
    }

    static let iconOptions: [IconOption] = [
        IconOption(symbol: "wallet.pass", label: "Wallet"),
        IconOption(symbol: "creditcard", label: "Card"),
        IconOption(symbol: "piggy.bank", label: "Piggy Bank"),
        IconOption(symbol: "building.columns", label: "Bank"),
        IconOption(symbol: "banknote", label: "Cash"),
        IconOption(symbol: "dollarsign.circle", label: "Dollar")
    ]

    static let colorOptions: [ColorOption] = [
        ColorOption(label: "Blue", hex: "2B7FFF"),
        ColorOption(label: "Purple", hex: "AD46FF"),
        ColorOption(label: "Pink", hex: "F6339A"),
        ColorOption(label: "Green", hex: "00BC7D"),
        ColorOption(label: "Orange", hex: "FF8A00"),
        ColorOption(label: "Teal", hex: "00D5BE"),
        ColorOption(label: "Red", hex: "FF4D4F"),
        ColorOption(label: "Indigo", hex: "5B6CFF")
    ]
}
