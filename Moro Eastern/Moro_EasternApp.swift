//
//  Moro_EasternApp.swift
//  Moro Eastern
//
//  Created by Алкександр Степанов on 12.03.2026.
//

import SwiftUI

@main
struct Moro_EasternApp: App {
    @State private var appState    = AppState()
    @State private var marketStore = MarketStore()
    @State private var dishStore   = DishStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(marketStore)
                .environment(dishStore)
        }
    }
}
