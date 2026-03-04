import Foundation
import SwiftUI

@Observable
final class DeckStore {
    var decks: [Deck] = []
    var deckProgress: [UUID: DeckProgress] = [:]
    
    private let fileURL: URL
    private let progressURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsPath.appendingPathComponent("decks.json")
        progressURL = documentsPath.appendingPathComponent("progress.json")
        
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        load()
    }
    
    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            decks = SampleDecks.createAllDecks()
            save()
            loadProgress()
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            decks = try decoder.decode([Deck].self, from: data)
        } catch {
            print("Error loading decks: \(error)")
            decks = SampleDecks.createAllDecks()
        }
        
        loadProgress()
    }
    
    private func loadProgress() {
        guard FileManager.default.fileExists(atPath: progressURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: progressURL)
            deckProgress = try decoder.decode([UUID: DeckProgress].self, from: data)
        } catch {
            print("Error loading progress: \(error)")
        }
    }
    
    func save() {
        do {
            let data = try encoder.encode(decks)
            try data.write(to: fileURL)
            let progressData = try encoder.encode(deckProgress)
            try progressData.write(to: progressURL)
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func addDeck(_ deck: Deck) {
        decks.append(deck)
        save()
    }
    
    func deleteDeck(at offsets: IndexSet) {
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
    
    func getCardsForReview(for deckId: UUID) -> [Card] {
        let progress = getProgress(for: deckId)
        guard let deck = decks.first(where: { $0.id == deckId }) else { return [] }
        
        var progressDict: [UUID: CardProgress] = [:]
        for p in progress.cardsProgress {
            progressDict[p.cardId] = p
        }
        
        return SpacedRepetition.sortByPriority(cards: deck.cards, progress: progressDict)
    }
}
