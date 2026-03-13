import SwiftUI

struct MarketCardView: View {
    let market: Market
    var onView: () -> Void

    private let cardRadius: CGFloat = 24

    private var dateFormatted: String {
        guard let date = market.dateOfVisit else { return "—" }
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f.string(from: date)
    }

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
        Group {
            if let first = market.images.first {
                Image(uiImage: first)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.white.opacity(0.06)
                    Image(systemName: "photo")
                        .font(.system(size: screenHeight * 0.04))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .frame(height: screenHeight * 0.24)
        .clipped()
    }

    // MARK: – Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name
            Text(market.name)
                .font(.sfProSemibold(screenHeight * 0.036))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.top, screenHeight * 0.018)
                .padding(.horizontal, screenHeight * 0.022)

            // Location + Date row
            HStack {
                HStack(spacing: screenHeight * 0.005) {
                    Image("geoIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                    Text(market.country)
                        .font(.sfProSemibold(screenHeight * 0.018))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                Text(dateFormatted)
                    .font(.sfProSemibold(screenHeight * 0.018))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, screenHeight * 0.008)
            .padding(.horizontal, screenHeight * 0.022)

            // View button
            viewButton
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.top, screenHeight * 0.018)
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
