import Foundation

enum AppTab: Int, CaseIterable {
    case market = 0
    case dish = 1
    case timer = 2

    var title: String {
        switch self {
        case .market: return "Market"
        case .dish:   return "Dish"
        case .timer:  return "Timer"
        }
    }

    func iconName(selected: Bool) -> String {
        switch self {
        case .market: return selected ? "marketOn" : "marketOff"
        case .dish:   return selected ? "dishOn"   : "dishOff"
        case .timer:  return selected ? "timerOn"  : "timerOff"
        }
    }
}
