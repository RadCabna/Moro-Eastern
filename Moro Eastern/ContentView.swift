//
//  ContentView.swift
//  Moro Eastern
//
//  Created by Алкександр Степанов on 12.03.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .market

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                ZStack {
                    Image("background")
                        .resizable()
                        .ignoresSafeArea()

                    tabContent
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: screenHeight * 0.14)
            }

            BottomBarContainer(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var tabContent: some View {
        ZStack {
            MarketListView().opacity(selectedTab == .market ? 1 : 0)
            DishView()      .opacity(selectedTab == .dish   ? 1 : 0)
            TimerView()     .opacity(selectedTab == .timer  ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

struct BottomBarContainer: View {
    @Binding var selectedTab: AppTab
    @Environment(AppState.self) private var appState

    var body: some View {
        BottomBarView(selectedTab: $selectedTab)
            .padding(.bottom, screenHeight * 0.04)
            .opacity(appState.showBottomBar ? 1 : 0)
            .offset(y: appState.showBottomBar ? 0 : screenHeight * 0.2)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: appState.showBottomBar)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(MarketStore())
        .environment(DishStore())
}
