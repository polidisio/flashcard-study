import Foundation
import CloudKit

enum SyncStatus: Equatable {
    case idle
    case syncing
    case synced
    case error(String)
    
    var icon: String {
        switch self {
        case .idle: return "cloud"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .synced: return "checkmark.icloud"
        case .error: return "exclamationmark.icloud"
        }
    }
}

enum ConflictResolution {
    case keepLocal
    case keepRemote
    case merge
}

struct CloudDeck: Codable {
    var id: UUID
    var name: String
    var cards: [CloudCard]
    var lastModified: Date
    var recordName: String?
    
    init(from deck: Deck) {
        self.id = deck.id
        self.name = deck.name
        self.cards = deck.cards.map { CloudCard(from: $0) }
        self.lastModified = deck.lastModified
    }
    
    func toDeck() -> Deck {
        Deck(
            id: id,
            name: name,
            cards: cards.map { $0.toCard() },
            lastModified: lastModified
        )
    }
}

struct CloudCard: Codable {
    var id: UUID
    var front: String
    var back: String
    var imageFront: String?
    var imageBack: String?
    var audioFront: String?
    var audioBack: String?
    
    init(from card: Card) {
        self.id = card.id
        self.front = card.front
        self.back = card.back
        self.imageFront = card.imageFront
        self.imageBack = card.imageBack
        self.audioFront = card.audioFront
        self.audioBack = card.audioBack
    }
    
    func toCard() -> Card {
        Card(
            id: id,
            front: front,
            back: back,
            imageFront: imageFront,
            imageBack: imageBack,
            audioFront: audioFront,
            audioBack: audioBack
        )
    }
}

@MainActor
class CloudManager: ObservableObject {
    static let shared = CloudManager()
    
    private let container = CKContainer.default()
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let deckRecordType = "Deck"
    private let mediaMaxSize: Int64 = 10 * 1024 * 1024 // 10MB
    
    private init() {}
    
    // MARK: - Sync Operations
    
    func syncAll(localDecks: [Deck]) async throws -> [Deck] {
        syncStatus = .syncing
        syncError = nil
        
        do {
            // Download remote decks
            let remoteDecks = try await downloadAllDecks()
            
            // Merge with local
            let mergedDecks = try mergeDecks(local: localDecks, remote: remoteDecks)
            
            // Upload local decks that are newer or don't exist remotely
            for deck in mergedDecks {
                try await uploadDeck(deck)
            }
            
            lastSyncDate = Date()
            syncStatus = .synced
            
            return mergedDecks
        } catch {
            syncStatus = .error(error.localizedDescription)
            syncError = error.localizedDescription
            throw error
        }
    }
    
    func uploadDeck(_ deck: Deck) async throws {
        let cloudDeck = CloudDeck(from: deck)
        _ = try await saveDeckToCloud(cloudDeck)
        
        // Upload media if exists
        for card in deck.cards {
            try await uploadCardMedia(card: card)
        }
    }
    
    func downloadAllDecks() async throws -> [Deck] {
        let query = CKQuery(recordType: deckRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        
        let (results, _) = try await privateDatabase.records(matching: query)
        
        var decks: [Deck] = []
        
        for (_, result) in results {
            if case .success(let record) = result {
                if let deck = try? decodeDeck(from: record) {
                    decks.append(deck)
                }
            }
        }
        
        return decks
    }
    
    func deleteDeck(deckId: UUID) async throws {
        let recordID = CKRecord.ID(recordName: deckId.uuidString)
        try await privateDatabase.deleteRecord(withID: recordID)
    }
    
    // MARK: - Merge Logic
    
    private func mergeDecks(local: [Deck], remote: [Deck]) throws -> [Deck] {
        var merged: [Deck] = []
        var processedIds = Set<UUID>()
        
        // Process all local decks
        for localDeck in local {
            if let remoteDeck = remote.first(where: { $0.id == localDeck.id }) {
                // Deck exists in both - check for conflicts
                if localDeck.lastModified > remoteDeck.lastModified {
                    // Local is newer - use local
                    merged.append(localDeck)
                } else if localDeck.lastModified < remoteDeck.lastModified {
                    // Remote is newer - use remote
                    merged.append(remoteDeck)
                } else {
                    // Same timestamp - use local (arbitrary)
                    merged.append(localDeck)
                }
            } else {
                // Only exists locally - keep it
                merged.append(localDeck)
            }
            processedIds.insert(localDeck.id)
        }
        
        // Add remote-only decks
        for remoteDeck in remote where !processedIds.contains(remoteDeck.id) {
            merged.append(remoteDeck)
        }
        
        return merged
    }
    
    // MARK: - Cloud Record Operations
    
    private func saveDeckToCloud(_ cloudDeck: CloudDeck) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: cloudDeck.id.uuidString)
        let record = CKRecord(recordType: deckRecordType, recordID: recordID)
        
        record["name"] = cloudDeck.name
        record["cards"] = encodeCards(cloudDeck.cards)
        record["lastModified"] = cloudDeck.lastModified
        
        return try await privateDatabase.save(record)
    }
    
    private func decodeDeck(from record: CKRecord) throws -> Deck {
        guard let name = record["name"] as? String,
              let cardsData = record["cards"] as? Data,
              let lastModified = record["lastModified"] as? Date else {
            throw CloudError.invalidRecord
        }
        
        let cards = try JSONDecoder().decode([CloudCard].self, from: cardsData)
        
        return Deck(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            name: name,
            cards: cards.map { $0.toCard() },
            lastModified: lastModified
        )
    }
    
    // MARK: - Media
    
    func uploadCardMedia(card: Card) async throws {
        // Upload front image
        if let imagePath = card.imageFront {
            try await uploadFile(at: imagePath, cardId: card.id, type: "imageFront")
        }
        
        // Upload back image
        if let imagePath = card.imageBack {
            try await uploadFile(at: imagePath, cardId: card.id, type: "imageBack")
        }
        
        // Upload front audio
        if let audioPath = card.audioFront {
            try await uploadFile(at: audioPath, cardId: card.id, type: "audioFront")
        }
        
        // Upload back audio
        if let audioPath = card.audioBack {
            try await uploadFile(at: audioPath, cardId: card.id, type: "audioBack")
        }
    }
    
    private func uploadFile(at path: String, cardId: UUID, type: String) async throws {
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: path) else { return }
        
        let attributes = try fileManager.attributesOfItem(atPath: path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        guard fileSize <= mediaMaxSize else {
            throw CloudError.mediaTooLarge
        }
        
        let data = try Data(contentsOf: url)
        
        // Save to CloudKit as separate record with asset
        let recordType = "Media"
        let recordID = CKRecord.ID(recordName: "\(cardId.uuidString)_\(type)")
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        // Store media data in UserDefaults or file for now (simplified)
        // In production, use CKAsset with CloudKit container
        let mediaKey = "\(cardId.uuidString)_\(type)"
        UserDefaults.standard.set(data, forKey: mediaKey)
        
        record["cardId"] = cardId.uuidString
        record["type"] = type
        record["data"] = data
        
        _ = try await privateDatabase.save(record)
    }
    
    func downloadCardMedia(cardId: UUID, type: String) async throws -> Data? {
        let recordID = CKRecord.ID(recordName: "\(cardId.uuidString)_\(type)")
        
        do {
            let record = try await privateDatabase.record(for: recordID)
            if let data = record["data"] as? Data {
                return data
            }
        } catch {
            // Try local cache
            let mediaKey = "\(cardId.uuidString)_\(type)"
            return UserDefaults.standard.data(forKey: mediaKey)
        }
        
        return nil
    }
    
    // MARK: - Helpers
    
    private func encodeCards(_ cards: [CloudCard]) -> Data {
        try! JSONEncoder().encode(cards)
    }
    
    func detectConflict(local: Deck, remote: Deck) -> Bool {
        let localDate = local.lastModified
        let remoteDate = remote.lastModified
        
        // Consider it a conflict if both have been modified within 1 minute
        return abs(localDate.timeIntervalSince(remoteDate)) < 60
    }
    
    // MARK: - Account Status
    
    func checkAccountStatus() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
}

enum CloudError: Error, LocalizedError {
    case invalidRecord
    case mediaTooLarge
    case notAuthenticated
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidRecord: return "Invalid cloud record"
        case .mediaTooLarge: return "Media file too large (max 10MB)"
        case .notAuthenticated: return "Not signed in to iCloud"
        case .networkError: return "Network error"
        }
    }
}
