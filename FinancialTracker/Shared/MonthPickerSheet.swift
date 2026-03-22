import SwiftUI

// Sheet-based month picker used by the dashboard filter.
struct MonthPickerSheet: View {
    @Binding var selectedMonth: Date
    let maxDate: Date

    @Environment(\.dismiss) private var dismiss

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

            DatePicker(
                "",
                selection: $selectedMonth,
                in: ...maxDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

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
    }
}

#Preview("Month Picker Sheet") {
    MonthPickerSheet(selectedMonth: .constant(Date()), maxDate: Date())
        .presentationDetents([.medium])
}
