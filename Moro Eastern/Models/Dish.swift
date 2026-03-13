import Foundation
import UIKit
import SwiftUI

enum TasteProfile: String, CaseIterable, Codable {
    case spicy      = "Spicy"
    case juicy      = "Juicy"
    case aromatic   = "Aromatic"
    case crunchy    = "Crunchy"
    case hearty     = "Hearty"
    case refreshing = "Refreshing"
    case salty      = "Salty"
    case smoky      = "Smoky"

    var iconName: String {
        switch self {
        case .spicy:      return "spicyIcon"
        case .juicy:      return "JuicyIcon"
        case .aromatic:   return "AromaticIcon"
        case .crunchy:    return "CrunchyIcon"
        case .hearty:     return "HeartyIcon"
        case .refreshing: return "RefreshingIcon"
        case .salty:      return "SaltyIcon"
        case .smoky:      return "SmokyIcon"
        }
    }

    var badgeColor: Color {
        switch self {
        case .spicy:      return Color(red: 1.0,  green: 0.22, blue: 0.22)
        case .juicy:      return Color(red: 0.22, green: 0.85, blue: 0.35)
        case .aromatic:   return Color(red: 1.0,  green: 0.55, blue: 0.1)
        case .crunchy:    return Color(red: 0.9,  green: 0.65, blue: 0.15)
        case .hearty:     return Color(red: 1.0,  green: 0.8,  blue: 0.0)
        case .refreshing: return Color(red: 0.0,  green: 0.85, blue: 1.0)
        case .smoky:      return Color(red: 0.35, green: 0.45, blue: 1.0)
        case .salty:      return Color(red: 0.85, green: 0.85, blue: 0.85)
        }
    }
}

struct Dish: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var price: String
    var tasteProfiles: [TasteProfile]
    var images: [UIImage]
    var ingredients: [Ingredient]
    var steps: [String]
    var description: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        country: String = "",
        price: String = "",
        tasteProfiles: [TasteProfile] = [],
        images: [UIImage] = [],
        ingredients: [Ingredient] = [],
        steps: [String] = [],
        description: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.price = price
        self.tasteProfiles = tasteProfiles
        self.images = images
        self.ingredients = ingredients
        self.steps = steps
        self.description = description
        self.createdAt = createdAt
    }

    // MARK: – Codable

    enum CodingKeys: String, CodingKey {
        case id, name, country, price, tasteProfiles, imagesData, ingredients, steps, description, createdAt
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,            forKey: .id)
        try c.encode(name,          forKey: .name)
        try c.encode(country,       forKey: .country)
        try c.encode(price,         forKey: .price)
        try c.encode(tasteProfiles, forKey: .tasteProfiles)
        let data = images.compactMap { $0.jpegData(compressionQuality: 0.7) }
        try c.encode(data,          forKey: .imagesData)
        try c.encode(ingredients,   forKey: .ingredients)
        try c.encode(steps,         forKey: .steps)
        try c.encode(description,   forKey: .description)
        try c.encode(createdAt,     forKey: .createdAt)
    }

    init(from decoder: Decoder) throws {
        let c   = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(UUID.self,           forKey: .id)
        name          = try c.decode(String.self,         forKey: .name)
        country       = try c.decode(String.self,         forKey: .country)
        price         = try c.decode(String.self,         forKey: .price)
        tasteProfiles = try c.decode([TasteProfile].self, forKey: .tasteProfiles)
        let data      = try c.decode([Data].self,         forKey: .imagesData)
        images        = data.compactMap { UIImage(data: $0) }
        ingredients   = try c.decode([Ingredient].self,   forKey: .ingredients)
        steps         = try c.decode([String].self,       forKey: .steps)
        description   = (try? c.decode(String.self,       forKey: .description)) ?? ""
        // Backward compat: existing records without createdAt get .distantPast → appear at bottom
        createdAt     = (try? c.decode(Date.self,         forKey: .createdAt)) ?? .distantPast
    }

    // MARK: – Hashable
    static func == (lhs: Dish, rhs: Dish) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
