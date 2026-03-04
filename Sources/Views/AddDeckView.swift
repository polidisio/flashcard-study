import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var xlsx: UTType {
        UTType(filenameExtension: "xlsx") ?? UTType.data
    }
}

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var deckName = ""
    @State private var importedCards: [Card] = []
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
                
                Section("Import Format") {
                    Toggle("Excel (.xlsx)", isOn: $useExcel)
                        .onChange(of: useExcel) { _, _ in
                            showingFilePicker = true
                        }
                }
                
                Section("Cards") {
                    if importedCards.isEmpty {
                        Text("No cards imported. Tap file picker above.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(importedCards.count) cards imported")
                            .foregroundStyle(.green)
                        
                        ForEach(importedCards.prefix(5)) { card in
                            VStack(alignment: .leading) {
                                Text(card.front)
                                    .font(.headline)
                                Text(card.back)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if importedCards.count > 5 {
                            Text("...and \(importedCards.count - 5) more")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Label("Select File", systemImage: "doc")
                    }
                }
            }
            .navigationTitle("New Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveDeck() }
                        .disabled(deckName.isEmpty)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: useExcel ? [.xlsx] : [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
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
                    errorMessage = "No valid cards found"
                    showingError = true
                }
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                showingError = true
            }
        case .failure(let error):
            errorMessage = "Error: \(error.localizedDescription)"
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
        
        var startIndex = 0
        if let firstLine = lines.first?.lowercased(),
           firstLine.contains("front") && firstLine.contains("back") {
            startIndex = 1
        }
        
        for i in startIndex..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            
            let fields = line.components(separatedBy: ",")
            if fields.count >= 2 {
                let front = fields[0].trimmingCharacters(in: .whitespaces)
                let back = fields[1].trimmingCharacters(in: .whitespaces)
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        return cards
    }
    
    private func parseExcel(url: URL) throws -> [Card] {
        let rows = try ExcelParser.parse(url: url)
        var cards: [Card] = []
        
        var startIndex = 0
        if let firstRow = rows.first,
           firstRow.count >= 2,
           firstRow[0].lowercased().contains("front") && firstRow[1].lowercased().contains("back") {
            startIndex = 1
        }
        
        for i in startIndex..<rows.count {
            let row = rows[i]
            if row.count >= 2 {
                let front = row[0].trimmingCharacters(in: .whitespaces)
                let back = row[1].trimmingCharacters(in: .whitespaces)
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        
        return cards
    }
    
    private func saveDeck() {
        let newDeck = Deck(name: deckName, cards: importedCards)
        decks.append(newDeck)
        dismiss()
    }
}

#Preview {
    AddDeckView(decks: .constant([]))
}
