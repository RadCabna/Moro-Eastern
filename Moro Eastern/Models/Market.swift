import Foundation
import UIKit

struct Market: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var dateOfVisit: Date?
    var images: [UIImage]
    var scent: String
    var sound: String
    var color: String
    var purchases: [Purchase]
    var proTip: String

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        dateOfVisit: Date? = nil,
        images: [UIImage] = [],
        scent: String = "",
        sound: String = "",
        color: String = "",
        purchases: [Purchase] = [],
        proTip: String = ""
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.dateOfVisit = dateOfVisit
        self.images = images
        self.scent = scent
        self.sound = sound
        self.color = color
        self.purchases = purchases
        self.proTip = proTip
    }

    // MARK: – Codable (UIImage <-> Data)

    enum CodingKeys: String, CodingKey {
        case id, name, country, dateOfVisit
        case imagesData
        case scent, sound, color, purchases, proTip
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(country, forKey: .country)
        try c.encodeIfPresent(dateOfVisit, forKey: .dateOfVisit)
        let data = images.compactMap { $0.jpegData(compressionQuality: 0.7) }
        try c.encode(data, forKey: .imagesData)
        try c.encode(scent, forKey: .scent)
        try c.encode(sound, forKey: .sound)
        try c.encode(color, forKey: .color)
        try c.encode(purchases, forKey: .purchases)
        try c.encode(proTip, forKey: .proTip)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(UUID.self, forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        country     = try c.decode(String.self, forKey: .country)
        dateOfVisit = try c.decodeIfPresent(Date.self, forKey: .dateOfVisit)
        let data    = try c.decode([Data].self, forKey: .imagesData)
        images      = data.compactMap { UIImage(data: $0) }
        scent       = try c.decode(String.self, forKey: .scent)
        sound       = try c.decode(String.self, forKey: .sound)
        color       = try c.decode(String.self, forKey: .color)
        purchases   = try c.decode([Purchase].self, forKey: .purchases)
        proTip      = try c.decode(String.self, forKey: .proTip)
    }

    // MARK: – Hashable (UIImage не поддерживает Hashable, хэшируем по id)

    static func == (lhs: Market, rhs: Market) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
