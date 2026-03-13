import SwiftUI

struct MarketListView: View {
    @Environment(MarketStore.self) private var store
    @Environment(AppState.self)    private var appState
    @State private var showAdd = false
    @State private var selectedMarket: Market? = nil

    // Newest dateOfVisit first; entries without a date go to the bottom
    private var sortedMarkets: [Market] {
        store.markets.sorted {
            ($0.dateOfVisit ?? .distantPast) > ($1.dateOfVisit ?? .distantPast)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if store.markets.isEmpty {
                emptyState
            } else {
                marketList
            }
        }
        .navigationDestination(isPresented: $showAdd) {
            AddMarketView()
        }
        .navigationDestination(item: $selectedMarket) { market in
            MarketDetailView(market: market)
        }
        .onChange(of: appState.popToRootMarket) {
            if appState.popToRootMarket {
                selectedMarket = nil
                appState.popToRootMarket = false
            }
        }
    }

    // MARK: – Header

    private var header: some View {
        ZStack {
            Text("Market List")
                .font(.sfProSemibold(screenHeight * 0.025))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Button { showAdd = true } label: {
                    Image("plusButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
                }
                .padding(.trailing, screenHeight * 0.025)
            }
        }
        .padding(.top, screenHeight * 0.02)
        .padding(.bottom, screenHeight * 0.02)
    }

    // MARK: – Empty State

    private var emptyState: some View {
        VStack(spacing: screenHeight * 0.01) {
            Text("No Markets Yet")
                .font(.sfProSemibold(screenHeight * 0.03))
                .foregroundColor(.white)

            Text("Start your first markets")
                .font(.sfProSemibold(screenHeight * 0.022))
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: – Market List

    private var marketList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: screenHeight * 0.018) {
                ForEach(sortedMarkets) { market in
                    MarketCardView(market: market) {
                        selectedMarket = market
                    }
                }
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.top, screenHeight * 0.01)
            .padding(.bottom, screenHeight * 0.16)
        }
    }
}

#Preview {
    ZStack {
        Image("background").resizable().ignoresSafeArea()
        MarketListView()
    }
    .environment(MarketStore())
}
