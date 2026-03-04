import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var cards: [Card]
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, cards: [Card] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.cards = cards
        self.createdAt = createdAt
    }
}
