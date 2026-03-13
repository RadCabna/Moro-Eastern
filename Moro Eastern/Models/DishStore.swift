import Foundation
import Observation

@Observable
class DishStore {
    var dishes: [Dish] = []

    @ObservationIgnored private let key     = "moro_dishes"
    @ObservationIgnored private let encoder = JSONEncoder()
    @ObservationIgnored private let decoder = JSONDecoder()

    init() { load() }

    func add(_ dish: Dish) {
        dishes.append(dish)
        save()
    }

    func update(_ dish: Dish) {
        if let i = dishes.firstIndex(where: { $0.id == dish.id }) {
            dishes[i] = dish
            save()
        }
    }

    func delete(_ dish: Dish) {
        dishes.removeAll { $0.id == dish.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        dishes.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        if let data = try? encoder.encode(dishes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data  = UserDefaults.standard.data(forKey: key),
              let saved = try? decoder.decode([Dish].self, from: data)
        else { return }
        dishes = saved
    }
}
