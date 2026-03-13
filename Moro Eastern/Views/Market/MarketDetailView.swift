import SwiftUI

struct MarketDetailView: View {
    let market: Market

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var scrolledPhotoID: Int? = 0
    @State private var showEdit = false

    private var photoIndex: Int { scrolledPhotoID ?? 0 }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            // Hero (photo carousel) is OUTSIDE ScrollView to avoid gesture conflict
            VStack(spacing: 0) {
                heroSection

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.028) {
                        sensorySection

                        if !market.purchases.filter({ !$0.item.isEmpty }).isEmpty {
                            acquisitionsSection
                        }

                        if !market.proTip.isEmpty {
                            proTipSection
                        }
                    }
                    .padding(.horizontal, screenHeight * 0.022)
                    .padding(.top, screenHeight * 0.028)
                    .padding(.bottom, screenHeight * 0.16)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Floating controls
            overlayControls
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showEdit) {
            AddMarketView(editing: market)
        }
        .onAppear  { appState.hideBar() }
        .onDisappear { appState.showBar() }
    }

    // MARK: – Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Photo carousel (horizontal ScrollView avoids gesture conflict with navigation)
            if market.images.isEmpty {
                ZStack {
                    Color.white.opacity(0.06)
                    Image(systemName: "photo")
                        .font(.system(size: screenHeight * 0.06))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(width: screenWidth, height: screenHeight * 0.48)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(market.images.indices, id: \.self) { i in
                            Image(uiImage: market.images[i])
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth, height: screenHeight * 0.48)
                                .clipped()
                                .id(i)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrolledPhotoID)
                .frame(width: screenWidth, height: screenHeight * 0.48)
                .scrollDisabled(market.images.count < 2)
            }

            // Bottom gradient — allowsHitTesting false so swipes pass through to ScrollView
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color(red: 0.04, green: 0.06, blue: 0.14).opacity(0.6), location: 0.4),
                    .init(color: Color(red: 0.04, green: 0.06, blue: 0.14), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: screenHeight * 0.28)
            .allowsHitTesting(false)

            // Name + Location + Dots — allowsHitTesting false so swipes pass through
            VStack(alignment: .leading, spacing: 0) {
                Text(market.name)
                    .font(.sfProSemibold(screenHeight * 0.042))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, screenHeight * 0.022)

                HStack(spacing: screenHeight * 0.006) {
                    Image("geoIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.02, height: screenHeight * 0.02)
                    Text(market.country.uppercased())
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(.top, screenHeight * 0.006)
                .padding(.horizontal, screenHeight * 0.022)

                if market.images.count > 1 {
                    pageDotsView
                        .padding(.top, screenHeight * 0.014)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, screenHeight * 0.022)
            .allowsHitTesting(false)
        }
        .frame(height: screenHeight * 0.48)
        .clipped()
    }

    // MARK: – Page Dots

    private var pageDotsView: some View {
        let count   = market.images.count
        let hMargin = screenHeight * 0.022
        let gap     = screenHeight * 0.01
        let totalGaps = gap * CGFloat(count - 1)
        let indWidth  = (screenWidth - hMargin * 2 - totalGaps) / CGFloat(count)
        let indHeight = screenHeight * 0.006

        return HStack(spacing: gap) {
            ForEach(market.images.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: indHeight / 2)
                    .fill(i == photoIndex ? Color.white : Color.white.opacity(0.35))
                    .frame(width: indWidth, height: indHeight)
                    .animation(.easeInOut(duration: 0.25), value: photoIndex)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: – Overlay Controls (back + edit)

    private var editButton: some View {
        Button { showEdit = true } label: {
            Image("editButton")
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
        }
        .buttonStyle(.plain)
    }

    private var overlayControls: some View {
        VStack {
            HStack {
                glassCircleButton(icon: "chevron.left") { dismiss() }
                Spacer()
                editButton
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.top, screenHeight * 0.014)
            Spacer()
        }
        // Safe-area top padding so buttons land just below the status bar
        .safeAreaPadding(.top, 0)
    }

    private func glassCircleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                TransparentBlurView()
                    .clipShape(Circle())
                    .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
                    .overlay(
                        Circle()
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

                Image(systemName: icon)
                    .font(.system(size: screenHeight * 0.018, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: – Sensory Profile

    private var sensorySection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            sectionTitle("Sensory Profile")

            HStack(spacing: screenHeight * 0.012) {
                sensoryCard(icon: "wind",        title: "SCENTS", value: market.scent)
                sensoryCard(icon: "waveform",    title: "SOUNDS", value: market.sound)
                sensoryCard(icon: "paintpalette",title: "COLOR",  value: market.color)
            }
        }
    }

    private func sensoryCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: screenHeight * 0.01) {
            Image(systemName: icon)
                .font(.system(size: screenHeight * 0.028, weight: .medium))
                .foregroundColor(Color("textColor_1"))
                .frame(height: screenHeight * 0.036)

            Text(title)
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white)

            Text(value.isEmpty ? "—" : value)
                .font(.sfProSemibold(screenHeight * 0.014))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, screenHeight * 0.02)
        .padding(.horizontal, screenHeight * 0.008)
        .background(sectionBackground)
    }

    // MARK: – Acquisitions

    private var acquisitionsSection: some View {
        let filtered = market.purchases.filter { !$0.item.isEmpty }

        return VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            sectionTitle("Acquisitions")

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("ITEM")
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(Color("textColor_1"))
                    Spacer()
                    Text("PRICE")
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(Color("textColor_1"))
                }
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.014)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, screenHeight * 0.014)
                .padding(.top, screenHeight * 0.014)

                // Rows
                ForEach(filtered) { purchase in
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, screenHeight * 0.014)

                        HStack {
                            Text(purchase.item)
                                .font(.sfProSemibold(screenHeight * 0.017))
                                .foregroundColor(.white)
                            Spacer()
                            Text(purchase.price.isEmpty ? "—" : purchase.price)
                                .font(.sfProSemibold(screenHeight * 0.017))
                                .foregroundColor(Color("textColor_1"))
                        }
                        .padding(.horizontal, screenHeight * 0.022)
                        .padding(.vertical, screenHeight * 0.016)
                    }
                }

                Spacer(minLength: screenHeight * 0.008)
            }
            .background(sectionBackground)
        }
    }

    // MARK: – Pro Tip

    private var proTipSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            sectionTitle("Pro Tip")

            VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                HStack(spacing: screenHeight * 0.01) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: screenHeight * 0.02, weight: .semibold))
                    Text("CONNOISSEUR PRO-TIP")
                        .font(.sfProSemibold(screenHeight * 0.016))
                }
                .foregroundColor(.white)

                Text(market.proTip)
                    .font(.sfProSemibold(screenHeight * 0.016))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(screenHeight * 0.022)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.022)
                    .fill(
                        LinearGradient(
                            colors: [Color("textColor_1").opacity(0.75), Color("textColor_1").opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: screenHeight * 0.022)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: – Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.sfProSemibold(screenHeight * 0.024))
            .foregroundColor(.white)
    }

    private var sectionBackground: some View {
        ZStack {
            TransparentBlurView()
            Color(red: 0.06, green: 0.08, blue: 0.18).opacity(0.6)
            RoundedRectangle(cornerRadius: screenHeight * 0.022)
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
        }
        .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.022))
    }
}

#Preview {
    NavigationStack {
        MarketDetailView(market: Market(
            name: "Grand Bazaar",
            country: "Istanbul, Turkey",
            dateOfVisit: Date(),
            scent: "Saffron & Oud",
            sound: "Copper Chimes",
            color: "Amber & Teal",
            purchases: [
                Purchase(item: "Hand-Woven Silk Kilim", price: "$1,250"),
                Purchase(item: "Ceramic Lamp",          price: "$340"),
            ],
            proTip: "For the most authentic experience, venture past the main tourist corridors into the Han sections."
        ))
    }
    .environment(AppState())
    .environment(MarketStore())
}
