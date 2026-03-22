import SwiftUI
import SwiftData

struct AddGoalSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var selectedEmoji: String
    @State private var selectedColorHex: String
    @State private var name: String
    @State private var targetAmount: Decimal
    @State private var currentAmount: Decimal
    @State private var hasDeadline: Bool
    @State private var deadline: Date

    private let existingGoal: Goal?

    init(isPresented: Binding<Bool>, existingGoal: Goal? = nil) {
        _isPresented = isPresented
        self.existingGoal = existingGoal

        _selectedEmoji = State(initialValue: existingGoal?.emoji ?? Self.iconOptions.first ?? "🎯")
        _selectedColorHex = State(initialValue: existingGoal?.colorHex ?? Self.colorOptions.first?.hex ?? "2B7FFF")
        _name = State(initialValue: existingGoal?.name ?? "")
        _targetAmount = State(initialValue: Decimal(existingGoal?.targetAmount ?? 0))
        _currentAmount = State(initialValue: Decimal(existingGoal?.currentAmount ?? 0))
        _hasDeadline = State(initialValue: existingGoal?.deadline != nil)
        _deadline = State(initialValue: existingGoal?.deadline ?? Date())
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
                    Text(existingGoal == nil ? "Create Savings Goal" : "Edit Savings Goal")
                        .font(.system(size: 22, weight: .bold))
                    Text("Set a target amount and track your progress")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }

                iconPicker
                colorPicker

                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Name")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("e.g., Emergency Fund", text: $name)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Amount")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("$0.00", value: $targetAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Amount")
                        .font(.system(size: 16, weight: .semibold))
                    TextField("$0.00", value: $currentAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Target Date (Optional)", isOn: $hasDeadline)
                        .font(.system(size: 16, weight: .semibold))
                    if hasDeadline {
                        DatePicker(
                            "Target Date",
                            selection: $deadline,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                    }
                }
                .padding(.top, 4)

                Button {
                    saveGoal()
                } label: {
                    Text(existingGoal == nil ? "Create Goal" : "Save Changes")
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(Self.iconOptions, id: \.self) { icon in
                    Button {
                        selectedEmoji = icon
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.04))
                            Text(icon)
                                .font(.system(size: 24))
                        }
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selectedEmoji == icon ? Color.black.opacity(0.4) : Color.clear, lineWidth: 2)
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
            HStack(spacing: 12) {
                ForEach(Self.colorOptions) { option in
                    Button {
                        selectedColorHex = option.hex
                    } label: {
                        Circle()
                            .fill(option.color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(selectedColorHex == option.hex ? 0.6 : 0), lineWidth: 2)
                            )
                    }
                }
            }
        }
    }

    private func saveGoal() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let target = NSDecimalNumber(decimal: targetAmount).doubleValue
        guard target > 0 else { return }
        let current = NSDecimalNumber(decimal: currentAmount).doubleValue
        let finalDeadline = hasDeadline ? deadline : nil

        if let goal = existingGoal {
            goal.name = trimmedName
            goal.targetAmount = target
            goal.currentAmount = current
            goal.deadline = finalDeadline
            goal.emoji = selectedEmoji
            goal.colorHex = selectedColorHex
        } else {
            let goal = Goal(
                name: trimmedName,
                targetAmount: target,
                currentAmount: current,
                deadline: finalDeadline,
                emoji: selectedEmoji,
                colorHex: selectedColorHex
            )
            modelContext.insert(goal)
        }

        try? modelContext.save()
        isPresented = false
    }

    private var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = NSDecimalNumber(decimal: targetAmount).doubleValue
        return !trimmedName.isEmpty && target > 0
    }
}

private extension AddGoalSheet {
    static let iconOptions: [String] = ["🏠", "🚗", "✈️", "💍", "🎓", "💻", "🎯", "🎁"]

    struct ColorOption: Identifiable {
        let id = UUID()
        let hex: String
        var color: Color { Color(hex: hex) }
    }

    static let colorOptions: [ColorOption] = [
        ColorOption(hex: "2B7FFF"),
        ColorOption(hex: "00D3F3"),
        ColorOption(hex: "00BC7D"),
        ColorOption(hex: "F6339A"),
        ColorOption(hex: "FF637E"),
        ColorOption(hex: "AD46FF"),
        ColorOption(hex: "FFD166")
    ]
}
