import Foundation
import Observation

@Observable
class MarketStore {
    var markets: [Market] = []

    @ObservationIgnored private let key = "moro_markets"
    @ObservationIgnored private let encoder = JSONEncoder()
    @ObservationIgnored private let decoder = JSONDecoder()

    init() {
        load()
    }

    func add(_ market: Market) {
        markets.append(market)
        save()
    }

    func update(_ market: Market) {
        if let i = markets.firstIndex(where: { $0.id == market.id }) {
            markets[i] = market
            save()
        }
    }

    func delete(_ market: Market) {
        markets.removeAll { $0.id == market.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        markets.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        if let data = try? encoder.encode(markets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? decoder.decode([Market].self, from: data)
        else { return }
        markets = saved
    }
}
