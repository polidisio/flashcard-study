import Foundation
import ZIPFoundation
import SQLite

enum APKImporterError: Error, LocalizedError {
    case invalidFile
    case extractionFailed
    case databaseNotFound
    case databaseError(String)
    case noCardsFound
    
    var errorDescription: String? {
        switch self {
        case .invalidFile: return "Invalid APK file"
        case .extractionFailed: return "Failed to extract APK file"
        case .databaseNotFound: return "Database not found in APK"
        case .databaseError(let msg): return "Database error: \(msg)"
        case .noCardsFound: return "No cards found in deck"
        }
    }
}

struct APKImportResult {
    var deckName: String
    var cards: [Card]
    var mediaMapping: [String: String] // Anki filename -> our path
}

class APKImporter {
    private let fileManager = FileManager.default
    private let mediaManager = MediaManager.shared
    
    func importAPK(from url: URL) async throws -> APKImportResult {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        defer {
            try? fileManager.removeItem(at: tempDir)
        }
        
        try extractAPK(from: url, to: tempDir)
        
        let dbPath = tempDir.appendingPathComponent("collection.anki2")
        
        guard fileManager.fileExists(atPath: dbPath.path) else {
            throw APKImporterError.databaseNotFound
        }
        
        return try await parseDatabase(at: dbPath, tempDir: tempDir)
    }
    
    private func extractAPK(from url: URL, to destination: URL) throws {
        guard let archive = Archive(url: url, accessMode: .read) else {
            throw APKImporterError.invalidFile
        }
        
        for entry in archive {
            let entryPath = destination.appendingPathComponent(entry.path)
            
            if entry.path.hasSuffix("/") {
                try fileManager.createDirectory(at: entryPath, withIntermediateDirectories: true)
            } else {
                let parentDir = entryPath.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: parentDir.path) {
                    try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
                }
                _ = try archive.extract(entry, to: entryPath)
            }
        }
    }
    
    private func parseDatabase(at dbPath: URL, tempDir: URL) async throws -> APKImportResult {
        let db = try Connection(dbPath.path)
        
        let notesTable = Table("notes")
        let cardsTable = Table("cards")
        
        let id = Expression<Int64>("id")
        let mid = Expression<Int64>("mid")
        let flds = Expression<String>("flds")
        let tags = Expression<String>("tags")
        
        let nid = Expression<Int64>("nid")
        let ord = Expression<Int64>("ord")
        let did = Expression<Int64>("did")
        
        var deckName = "Imported Deck"
        
        var cards: [Card] = []
        var mediaMapping: [String: String] = [:]
        
        var fieldNames: [Int64: [String]] = [:]
        let modelsTable = Table("models")
        let modelId = Expression<Int64>("id")
        let modelFlds = Expression<String>("flds")
        
        do {
            for row in try db.prepare(modelsTable) {
                let modelIdValue = row[modelId]
                let fieldsJson = row[modelFlds]
                
                if let fieldData = parseAnkiFields(fieldsJson) {
                    fieldNames[modelIdValue] = fieldData
                }
            }
        } catch {
            print("Could not read models: \(error)")
        }
        
        var notesData: [(id: Int64, mid: Int64, fields: String)] = []
        
        do {
            for row in try db.prepare(notesTable) {
                notesData.append((id: row[id], mid: row[mid], fields: row[flds]))
            }
        } catch {
            throw APKImporterError.databaseError(error.localizedDescription)
        }
        
        let mediaDir = tempDir.appendingPathComponent("media")
        var mediaFiles: [String: String] = [:]
        
        if fileManager.fileExists(atPath: mediaDir.path) {
            if let contents = try? fileManager.contentsOfDirectory(at: mediaDir, includingPropertiesForKeys: nil) {
                for file in contents {
                    mediaFiles[file.lastPathComponent] = file.path
                }
            }
        }
        
        for note in notesData {
            let fieldNamesForModel = fieldNames[note.mid] ?? ["Front", "Back"]
            let fields = parseFields(note.fields, fieldCount: fieldNamesForModel.count)
            
            guard fields.count >= 2 else { continue }
            
            var front = fields[0]
            var back = fields[1]
            var imageFront: String?
            var imageBack: String?
            var audioFront: String?
            var audioBack: String?
            
            let cardId = UUID()
            let cardMediaDir = mediaManager.cardMediaDirectory(for: cardId)
            
            front = extractAndCopyMedia(from: front, mediaFiles: mediaFiles, cardMediaDir: cardMediaDir, mediaMapping: &mediaMapping, isFront: true)
            back = extractAndCopyMedia(from: back, mediaFiles: mediaFiles, cardMediaDir: cardMediaDir, mediaMapping: &mediaMapping, isFront: false)
            
            if let imgFront = findImagePath(in: front) {
                imageFront = mediaMapping[imgFront]
                front = front.replacingOccurrences(of: "<img src=\"\(imgFront)\">", with: "")
                front = front.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let imgBack = findImagePath(in: back) {
                imageBack = mediaMapping[imgBack]
                back = back.replacingOccurrences(of: "<img src=\"\(imgBack)\">", with: "")
                back = back.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let audFront = findAudioPath(in: front) {
                audioFront = mediaMapping[audFront]
                front = front.replacingOccurrences(of: "[sound:\(audFront)]", with: "")
                front = front.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let audBack = findAudioPath(in: back) {
                audioBack = mediaMapping[audBack]
                back = back.replacingOccurrences(of: "[sound:\(audBack)]", with: "")
                back = back.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            let card = Card(
                id: cardId,
                front: cleanHTML(front),
                back: cleanHTML(back),
                imageFront: imageFront,
                imageBack: imageBack,
                audioFront: audioFront,
                audioBack: audioBack
            )
            
            cards.append(card)
        }
        
        if cards.isEmpty {
            throw APKImporterError.noCardsFound
        }
        
        return APKImportResult(deckName: deckName, cards: cards, mediaMapping: mediaMapping)
    }
    
    private func parseAnkiFields(_ json: String) -> [String]? {
        guard let data = json.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }
        
        return array.compactMap { $0["name"] as? String }
    }
    
    private func parseFields(_ fieldsString: String, fieldCount: Int) -> [String] {
        let fields = fieldsString.components(separatedBy: "\u{1F}")
        return Array(fields.prefix(fieldCount))
    }
    
    private func extractAndCopyMedia(from text: String, mediaFiles: [String: String], cardMediaDir: URL, mediaMapping: inout [String: String], isFront: Bool) -> String {
        var result = text
        
        let audioPattern = "\\[sound:([^\\]]+)\\]"
        if let regex = try? NSRegularExpression(pattern: audioPattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range)
            
            for match in matches.reversed() {
                if let soundRange = Range(match.range(at: 1), in: result) {
                    let filename = String(result[soundRange])
                    
                    if let sourcePath = mediaFiles[filename] {
                        let destPath = cardMediaDir.appendingPathComponent(filename)
                        
                        if !fileManager.fileExists(atPath: destPath.path) {
                            try? fileManager.copyItem(atPath: sourcePath, toPath: destPath.path)
                        }
                        
                        mediaMapping[filename] = destPath.path
                    }
                }
            }
        }
        
        let imagePattern = "<img src=\"([^\"]+)\">"
        if let regex = try? NSRegularExpression(pattern: imagePattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range)
            
            for match in matches.reversed() {
                if let srcRange = Range(match.range(at: 1), in: result) {
                    let filename = String(result[srcRange])
                    
                    if let sourcePath = mediaFiles[filename] {
                        let destPath = cardMediaDir.appendingPathComponent(filename)
                        
                        if !fileManager.fileExists(atPath: destPath.path) {
                            try? fileManager.copyItem(atPath: sourcePath, toPath: destPath.path)
                        }
                        
                        mediaMapping[filename] = destPath.path
                    }
                }
            }
        }
        
        return result
    }
    
    private func findImagePath(in text: String) -> String? {
        let pattern = "<img src=\"([^\"]+)\">"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }
    
    private func findAudioPath(in text: String) -> String? {
        let pattern = "\\[sound:([^\\]]+)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }
    
    private func cleanHTML(_ text: String) -> String {
        var result = text
        
        result = result.replacingOccurrences(of: "<br>", with: "\n")
        result = result.replacingOccurrences(of: "<br/>", with: "\n")
        result = result.replacingOccurrences(of: "<br />", with: "\n")
        result = result.replacingOccurrences(of: "<div>", with: "\n")
        result = result.replacingOccurrences(of: "</div>", with: "")
        
        let tagPattern = "<[^>]+>"
        if let regex = try? NSRegularExpression(pattern: tagPattern) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "")
        }
        
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
}
