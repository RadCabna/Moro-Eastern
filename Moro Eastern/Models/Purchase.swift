import Foundation

struct Purchase: Identifiable, Codable, Hashable {
    let id: UUID
    var item: String
    var price: String

    init(id: UUID = UUID(), item: String = "", price: String = "") {
        self.id = id
        self.item = item
        self.price = price
    }
}
