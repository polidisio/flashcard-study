import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var cards: [Card]
    var createdAt: Date
    var lastModified: Date
    var color: String
    
    static let deckColors = [
        "red", "orange", "yellow", "green", "mint", "teal", "blue", "indigo", "purple", "pink", "brown"
    ]
    
    init(id: UUID = UUID(), name: String, cards: [Card] = [], createdAt: Date = Date(), lastModified: Date = Date(), color: String = "blue") {
        self.id = id
        self.name = name
        self.cards = cards
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.color = color
    }
}
