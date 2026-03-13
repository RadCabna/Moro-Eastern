import Observation

@Observable
class AppState {
    // Counter: bar is visible only when no view is hiding it
    private var hideCount = 0

    var showBottomBar: Bool { hideCount == 0 }

    func hideBar() { hideCount += 1 }
    func showBar() { hideCount = max(0, hideCount - 1) }

    // Pop-to-root signals for each tab
    var popToRootMarket = false
    var popToRootDish   = false
}
