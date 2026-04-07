import SwiftUI

struct WhatsNewSheet: View {
    @Binding var isPresented: Bool

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

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.purple.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColors.purple)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What's New")
                            .font(.system(size: 22, weight: .bold))
                        Text("Version 1.2.0")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                ForEach(Self.sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            if section.isNew {
                                Text("NEW")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.blue.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            Text(section.date)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(section.items, id: \.title) { item in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(AppColors.green)
                                        .padding(.top, 2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(Color(hex: "0A0A0A"))
                                        Text(item.detail)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }

                        Divider()
                            .padding(.top, 6)
                    }
                }

                Button {
                    UserDefaults.standard.set(true, forKey: "whats_new_seen_v1_2_0")
                    isPresented = false
                } label: {
                    Text("Got it!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
    }
}

private extension WhatsNewSheet {
    struct ReleaseItem {
        let title: String
        let detail: String
    }

    struct ReleaseSection: Identifiable {
        let id = UUID()
        let date: String
        let isNew: Bool
        let items: [ReleaseItem]
    }

    static let sections: [ReleaseSection] = [
        ReleaseSection(
            date: "April 7, 2026",
            isNew: true,
            items: [
                ReleaseItem(
                    title: "Custom Accounts",
                    detail: "Create unlimited accounts with custom icons and colors."
                ),
                ReleaseItem(
                    title: "Monthly Budgets",
                    detail: "Set spending limits per month and track progress automatically."
                ),
                ReleaseItem(
                    title: "Minor Fixes",
                    detail: "Various stability and UI improvements."
                )
            ]
        ),
        ReleaseSection(
            date: "March 28, 2026",
            isNew: false,
            items: [
                ReleaseItem(
                    title: "Savings Goals",
                    detail: "Create goals and track progress over time."
                ),
                ReleaseItem(
                    title: "Custom Categories",
                    detail: "Add your own transaction categories."
                )
            ]
        ),
        ReleaseSection(
            date: "March 22, 2026",
            isNew: false,
            items: [
                ReleaseItem(
                    title: "Initial Release",
                    detail: "Track income and expenses across accounts."
                ),
                ReleaseItem(
                    title: "Analytics & Charts",
                    detail: "View category-based spending analytics."
                )
            ]
        )
    ]
}
