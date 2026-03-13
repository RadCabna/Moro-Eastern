import SwiftUI

struct DishCardView: View {
    let dish: Dish
    var onView: () -> Void

    private let cardRadius: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            photoSection
            infoSection
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cardRadius)
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
    }

    // MARK: – Background

    private var cardBackground: some View {
        ZStack {
            TransparentBlurView()
            Color(red: 0.06, green: 0.08, blue: 0.16).opacity(0.75)
        }
    }

    // MARK: – Photo

    private var photoSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let first = dish.images.first {
                    Image(uiImage: first)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color.white.opacity(0.06)
                        Image(systemName: "fork.knife")
                            .font(.system(size: screenHeight * 0.04))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .frame(height: screenHeight * 0.24)
            .clipped()

            // Taste badges — all stacked vertically, right-aligned
            if !dish.tasteProfiles.isEmpty {
                VStack(alignment: .trailing, spacing: screenHeight * 0.006) {
                    ForEach(dish.tasteProfiles, id: \.self) { taste in
                        tasteBadge(taste)
                    }
                }
                .padding(.top, screenHeight * 0.012)
                .padding(.trailing, screenHeight * 0.012)
            }
        }
        .frame(height: screenHeight * 0.24)
        .clipped()
    }

    private func tasteBadge(_ taste: TasteProfile) -> some View {
        HStack(spacing: screenHeight * 0.005) {
            Image(taste.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.017, height: screenHeight * 0.017)
            Text(taste.rawValue.uppercased())
                .font(.sfProSemibold(screenHeight * 0.012))
                .foregroundColor(.white)
        }
        .padding(.horizontal, screenHeight * 0.01)
        .padding(.vertical, screenHeight * 0.006)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                .fill(Color.black.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: screenHeight * 0.016)
                        .stroke(taste.badgeColor, lineWidth: 1.5)
                )
        )
    }

    // MARK: – Info

    private var infoSection: some View {
        VStack(spacing: 0) {
            // Name + Price
            HStack(alignment: .firstTextBaseline) {
                Text(dish.name)
                    .font(.sfProSemibold(screenHeight * 0.03))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                if !dish.price.isEmpty {
                    Text("$\(dish.price)")
                        .font(.sfProSemibold(screenHeight * 0.022))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .padding(.top, screenHeight * 0.018)
            .padding(.horizontal, screenHeight * 0.022)

            // Country
            HStack(spacing: screenHeight * 0.005) {
                Image("geoIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenHeight * 0.018, height: screenHeight * 0.018)
                Text(dish.country)
                    .font(.sfProSemibold(screenHeight * 0.016))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top, screenHeight * 0.006)
            .padding(.horizontal, screenHeight * 0.022)

            // Description with vertical bar
            if !dish.description.isEmpty {
                HStack(alignment: .top, spacing: screenHeight * 0.012) {
                    Rectangle()
                        .fill(Color("textColor_1").opacity(0.8))
                        .frame(width: 2)
                    Text(dish.description)
                        .font(.sfProSemibold(screenHeight * 0.015))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, screenHeight * 0.012)
                .padding(.horizontal, screenHeight * 0.022)
            }

            // View button
            viewButton
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.top, screenHeight * 0.016)
                .padding(.bottom, screenHeight * 0.018)
        }
    }

    // MARK: – View Button

    private var viewButton: some View {
        Button(action: onView) {
            HStack(spacing: screenHeight * 0.008) {
                Text("VIEW")
                    .font(.sfProSemibold(screenHeight * 0.02))
                Image(systemName: "arrow.right")
                    .font(.system(size: screenHeight * 0.018, weight: .semibold))
            }
            .foregroundColor(Color("textColor_1"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, screenHeight * 0.016)
            .background(Capsule().fill(Color.white))
        }
        .buttonStyle(.plain)
    }
}
