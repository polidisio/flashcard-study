import Foundation
import SwiftUI

@Observable
final class DeckStore {
    var decks: [Deck] = []
    var deckProgress: [UUID: DeckProgress] = [:]
    var cardStats: [UUID: [UUID: CardStats]] = [:] // deckId -> cardId -> stats
    var deckStats: [UUID: DeckStats] = [:]
    
    private let fileURL: URL
    private let progressURL: URL
    private let statsURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsPath.appendingPathComponent("decks.json")
        progressURL = documentsPath.appendingPathComponent("progress.json")
        statsURL = documentsPath.appendingPathComponent("stats.json")
        
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        load()
    }
    
    func load() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            decks = SampleDecks.createAllDecks()
            for deck in decks {
                cardStats[deck.id] = [:]
                deckStats[deck.id] = DeckStats()
            }
            save()
            loadProgress()
            loadStats()
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            decks = try decoder.decode([Deck].self, from: data)
        } catch {
            print("Error loading decks: \(error)")
            decks = SampleDecks.createAllDecks()
        }
        
        for deck in decks {
            if cardStats[deck.id] == nil {
                cardStats[deck.id] = [:]
            }
            if deckStats[deck.id] == nil {
                deckStats[deck.id] = DeckStats()
            }
        }
        
        loadProgress()
        loadStats()
    }
    
    private func loadProgress() {
        guard FileManager.default.fileExists(atPath: progressURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: progressURL)
            deckProgress = try decoder.decode([UUID: DeckProgress].self, from: data)
        } catch {
            print("Error loading progress: \(error)")
        }
    }
    
    private func loadStats() {
        guard FileManager.default.fileExists(atPath: statsURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: statsURL)
            let statsData = try decoder.decode(StatsData.self, from: data)
            cardStats = statsData.cardStats
            deckStats = statsData.deckStats
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    func save() {
        do {
            let data = try encoder.encode(decks)
            try data.write(to: fileURL)
            let progressData = try encoder.encode(deckProgress)
            try progressData.write(to: progressURL)
            
            let statsData = StatsData(cardStats: cardStats, deckStats: deckStats)
            let statsDataEncoded = try encoder.encode(statsData)
            try statsDataEncoded.write(to: statsURL)
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func addDeck(_ deck: Deck) {
        decks.append(deck)
        cardStats[deck.id] = [:]
        deckStats[deck.id] = DeckStats()
        save()
    }
    
    func deleteDeck(at offsets: IndexSet) {
        for index in offsets {
            let deckId = decks[index].id
            cardStats.removeValue(forKey: deckId)
            deckStats.removeValue(forKey: deckId)
        }
        decks.remove(atOffsets: offsets)
        save()
    }
    
    func updateDeck(_ deck: Deck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            save()
        }
    }
    
    func renameDeck(at index: Int, to newName: String) {
        guard index < decks.count else { return }
        decks[index].name = newName
        save()
    }
    
    // MARK: - Progress
    
    func getProgress(for deckId: UUID) -> DeckProgress {
        if let progress = deckProgress[deckId] {
            return progress
        }
        let newProgress = DeckProgress(deckId: deckId)
        deckProgress[deckId] = newProgress
        return newProgress
    }
    
    func updateCardProgress(_ progress: CardProgress, for deckId: UUID) {
        if deckProgress[deckId] == nil {
            deckProgress[deckId] = DeckProgress(deckId: deckId)
        }
        deckProgress[deckId]?.updateProgress(progress)
        save()
    }
    
    func updateDeckProgress(_ progress: DeckProgress, for deckId: UUID) {
        deckProgress[deckId] = progress
        save()
    }
    
    func getCardsForReview(for deckId: UUID) -> [Card] {
        let progress = getProgress(for: deckId)
        guard let deck = decks.first(where: { $0.id == deckId }) else { return [] }
        
        var progressDict: [UUID: CardProgress] = [:]
        for p in progress.cardsProgress {
            progressDict[p.cardId] = p
        }
        
        return SpacedRepetition.sortByPriority(cards: deck.cards, progress: progressDict)
    }
    
    // MARK: - Stats
    
    func getCardStats(for cardId: UUID, in deckId: UUID) -> CardStats {
        if let deckCardStats = cardStats[deckId], let stats = deckCardStats[cardId] {
            return stats
        }
        return CardStats()
    }
    
    func updateCardStats(_ stats: CardStats, for cardId: UUID, in deckId: UUID) {
        if cardStats[deckId] == nil {
            cardStats[deckId] = [:]
        }
        cardStats[deckId]?[cardId] = stats
        save()
    }
    
    func getDeckStats(for deckId: UUID) -> DeckStats {
        if let stats = deckStats[deckId] {
            return stats
        }
        return DeckStats()
    }
    
    func updateDeckStats(for deckId: UUID) {
        guard let deck = decks.first(where: { $0.id == deckId }),
              let deckCardStats = cardStats[deckId] else { return }
        
        var stats = getDeckStats(for: deckId)
        stats.totalCards = deck.cards.count
        stats.update(with: Array(deckCardStats.values))
        deckStats[deckId] = stats
        save()
    }
    
    func getAllCardStats(for deckId: UUID) -> [UUID: CardStats] {
        return cardStats[deckId] ?? [:]
    }
    
    func resetStats(for deckId: UUID) {
        cardStats[deckId] = [:]
        deckStats[deckId] = DeckStats()
        save()
    }
    
    func resetAllStats() {
        cardStats = [:]
        deckStats = [:]
        save()
    }
}

private struct StatsData: Codable {
    var cardStats: [UUID: [UUID: CardStats]]
    var deckStats: [UUID: DeckStats]
}
