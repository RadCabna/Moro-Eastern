import SwiftUI

struct BottomBarView: View {
    @Binding var selectedTab: AppTab

    private var barWidth:  CGFloat { screenWidth * 0.8 }
    private var barHeight: CGFloat { screenHeight * 0.09 }
    private var tabWidth:  CGFloat { barWidth / CGFloat(AppTab.allCases.count) }

    var body: some View {
        ZStack {
            TransparentBlurView()
                .clipShape(Capsule())
                .frame(width: barWidth, height: barHeight)
                .overlay(
                    Capsule()
                        .stroke(
                            AngularGradient(
                                stops: [
                                    .init(color: .white.opacity(0.7),  location: 0.00),
                                    .init(color: .gray.opacity(0.35),  location: 0.12),
                                    .init(color: .black.opacity(0.05), location: 0.22),
                                    .init(color: .white.opacity(0.7),  location: 0.33),
                                    .init(color: .gray.opacity(0.35),  location: 0.45),
                                    .init(color: .black.opacity(0.05), location: 0.55),
                                    .init(color: .white.opacity(0.7),  location: 0.66),
                                    .init(color: .gray.opacity(0.35),  location: 0.78),
                                    .init(color: .black.opacity(0.05), location: 0.88),
                                    .init(color: .white.opacity(0.7),  location: 1.00),
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                )

            slidingIndicator

            tabButtons
        }
    }

    private var slidingIndicator: some View {
        Capsule()
            .fill(Color.white.opacity(0.1))
            .frame(width: tabWidth - screenHeight * 0.01, height: barHeight - screenHeight * 0.01)
            .offset(x: tabWidth * CGFloat(selectedTab.rawValue) - tabWidth)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedTab)
    }

    private var tabButtons: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(tab)
                    .frame(width: tabWidth, height: barHeight)
            }
        }
        .frame(width: barWidth)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: screenHeight * 0.005) {
                Image(tab.iconName(selected: isSelected))
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenHeight * 0.032, height: screenHeight * 0.032)

                Text(tab.title)
                    .font(.sfProSemibold(screenHeight * 0.014))
                    .foregroundColor(isSelected ? Color("textColor_1") : .white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BottomBarView(selectedTab: .constant(.market))
    }
}
