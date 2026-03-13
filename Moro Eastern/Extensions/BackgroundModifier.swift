import SwiftUI

private struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}
