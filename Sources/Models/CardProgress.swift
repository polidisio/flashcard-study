import Foundation

struct CardProgress: Codable, Identifiable {
    var id: UUID { cardId }
    let cardId: UUID
    var repetitions: Int
    var easeFactor: Double
    var interval: Int
    var nextReviewDate: Date
    
    init(cardId: UUID) {
        self.cardId = cardId
        self.repetitions = 0
        self.easeFactor = 2.5
        self.interval = 0
        self.nextReviewDate = Date()
    }
}

struct DeckProgress: Codable {
    let deckId: UUID
    var cardsProgress: [CardProgress]
    
    init(deckId: UUID) {
        self.deckId = deckId
        self.cardsProgress = []
    }
    
    mutating func getProgress(for cardId: UUID) -> CardProgress {
        if let index = cardsProgress.firstIndex(where: { $0.cardId == cardId }) {
            return cardsProgress[index]
        }
        let newProgress = CardProgress(cardId: cardId)
        cardsProgress.append(newProgress)
        return newProgress
    }
    
    mutating func updateProgress(_ progress: CardProgress) {
        if let index = cardsProgress.firstIndex(where: { $0.cardId == progress.cardId }) {
            cardsProgress[index] = progress
        } else {
            cardsProgress.append(progress)
        }
    }
}
