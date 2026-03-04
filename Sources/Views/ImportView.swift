import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: @State private var deckName = ""
    @State private [Deck]
    var importedCards: [Card] = []
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var useExcel = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Enter deck name", text: $deckName)
                }
                
                Section("Format") {
                    Picker("Format", selection: $useExcel) {
                        Text("CSV").tag(false)
                        Text("Excel").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    Button("Select File") {
                        showingFilePicker = true
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section("Preview") {
                    if importedCards.isEmpty {
                        Text("No cards loaded")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(importedCards.count) cards ready")
                            .foregroundStyle(.green)
                        
                        ForEach(importedCards.prefix(3)) { card in
                            VStack(alignment: .leading) {
                                Text(card.front).font(.caption).bold()
                                Text(card.back).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        importDeck()
                    }
                    .disabled(deckName.isEmpty || importedCards.isEmpty)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: useExcel ? [.xlsx] : [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFile(result)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                if useExcel {
                    importedCards = try parseExcel(url: url)
                } else {
                    importedCards = try parseCSV(url: url)
                }
                if importedCards.isEmpty {
                    errorMessage = "No cards found"
                    showingError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func parseCSV(url: URL) throws -> [Card] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        return parseCSVContent(content)
    }
    
    private func parseCSVContent(_ content: String) -> [Card] {
        var cards: [Card] = []
        let lines = content.components(separatedBy: .newlines)
        
        var start = 0
        if let first = lines.first?.lowercased(), first.contains("front") {
            start = 1
        }
        
        for line in lines.dropFirst(start) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            let parts = trimmed.components(separatedBy: ",")
            if parts.count >= 2 {
                let front = parts[0].trimmingCharacters(in: .whitespaces)
                let back = parts[1].trimmingCharacters(in: .whitespaces)
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        return cards
    }
    
    private func parseExcel(url: URL) throws -> [Card] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let data = try Data(contentsOf: url)
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Parse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot read file"])
        }
        
        var cards: [Card] = []
        
        // Find all <row> elements
        let rowPattern = "<row[^>]*>(.*?)</row>"
        guard let regex = try? NSRegularExpression(pattern: rowPattern, options: [.dotMatchesLineSeparators]) else {
            return cards
        }
        
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex.matches(in: content, options: [], range: range)
        
        var startIndex = 0
        for (index, match) in matches.enumerated() {
            guard let rowRange = Range(match.range(at: 1), in: content) else { continue }
            let rowContent = String(content[rowRange])
            
            var rowData: [String] = []
            
            // Find all cell values
            let cellPattern = "<c[^>]*>(<is><t>(.*?)</t></is>|<v>(.*?)</v>)?</c>"
            let cellRegex = try? NSRegularExpression(pattern: cellPattern, options: [.dotMatchesLineSeparators])
            let cellRange = NSRange(rowContent.startIndex..., in: rowContent)
            
            if let cellMatches = cellRegex?.matches(in: rowContent, options: [], range: cellRange) {
                for cellMatch in cellMatches {
                    if let tRange = Range(cellMatch.range(at: 2), in: rowContent) {
                        rowData.append(String(rowContent[tRange]))
                    } else if let vRange = Range(cellMatch.range(at: 3), in: rowContent) {
                        rowData.append(String(rowContent[vRange]))
                    }
                }
            }
            
            // Skip header row
            if index == 0 && rowData.first?.lowercased().contains("front") == true {
                continue
            }
            
            if rowData.count >= 2 {
                let front = rowData[0].trimmingCharacters(in: .whitespaces)
                let back = rowData[1].trimmingCharacters(in: .whitespaces)
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        
        return cards
    }
    
    private func importDeck() {
        let newDeck = Deck(name: deckName, cards: importedCards)
        decks.append(newDeck)
        dismiss()
    }
}
