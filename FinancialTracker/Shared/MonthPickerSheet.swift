import SwiftUI

// Sheet-based month picker used by the dashboard filter.
struct MonthPickerSheet: View {
    @Binding var selectedMonth: Date
    let maxDate: Date

    @Environment(\.dismiss) private var dismiss
    @State private var selectedYear: Int
    @State private var selectedMonthIndex: Int

    init(selectedMonth: Binding<Date>, maxDate: Date) {
        _selectedMonth = selectedMonth
        self.maxDate = maxDate
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedMonth.wrappedValue)
        let month = calendar.component(.month, from: selectedMonth.wrappedValue)
        _selectedYear = State(initialValue: year)
        _selectedMonthIndex = State(initialValue: month)
    }

    // Sheet UI.
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }

            Text("Select Month")
                .font(.system(size: 20, weight: .bold))

            HStack(spacing: 12) {
                Picker("Month", selection: $selectedMonthIndex) {
                    ForEach(availableMonths, id: \.self) { month in
                        Text(Self.monthSymbols[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Year", selection: $selectedYear) {
                    ForEach(availableYears, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110)
                .clipped()
            }
            .frame(height: 160)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 6)
        }
        .padding(20)
        .onChange(of: selectedYear) { _, _ in
            clampMonthIfNeeded()
            updateSelectedDate()
        }
        .onChange(of: selectedMonthIndex) { _, _ in
            updateSelectedDate()
        }
    }

    private var availableYears: [Int] {
        let calendar = Calendar.current
        let maxYear = calendar.component(.year, from: maxDate)
        let minYear = max(2000, maxYear - 10)
        return Array(minYear...maxYear)
    }

    private var availableMonths: [Int] {
        let calendar = Calendar.current
        let maxYear = calendar.component(.year, from: maxDate)
        let maxMonth = calendar.component(.month, from: maxDate)
        if selectedYear == maxYear {
            return Array(1...maxMonth)
        }
        return Array(1...12)
    }

    private func clampMonthIfNeeded() {
        if !availableMonths.contains(selectedMonthIndex) {
            selectedMonthIndex = availableMonths.last ?? 1
        }
    }

    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonthIndex
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            selectedMonth = date
        }
    }
}

private extension MonthPickerSheet {
    static let monthSymbols = Calendar.current.monthSymbols
}

#Preview("Month Picker Sheet") {
    MonthPickerSheet(selectedMonth: .constant(Date()), maxDate: Date())
        .presentationDetents([.medium])
}
