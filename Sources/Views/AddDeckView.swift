import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var deckName = ""
    @State private var showingFilePicker = false
    @State private var importedCards: [Card] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Deck Name", text: $deckName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Divider()
                
                Text("Add Cards")
                    .font(.headline)
                
                Button {
                    showingFilePicker = true
                } label: {
                    Label("Import from CSV", systemImage: "doc.text")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.gothicAccent)
                
                if !importedCards.isEmpty {
                    Text("\(importedCards.count) cards imported")
                        .foregroundStyle(Color.gothicAccent)
                    
                    List(importedCards.prefix(5)) { card in
                        VStack(alignment: .leading) {
                            Text(card.front)
                                .font(.headline)
                            Text(card.back)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 150)
                    
                    if importedCards.count > 5 {
                        Text("...and \(importedCards.count - 5) more")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    createDeck()
                } label: {
                    Text("Create Deck")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.gothicAccent)
                .disabled(deckName.isEmpty)
            }
            .padding()
            .background(Color.gothicBackground)
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText],
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
            
            let accessing = url.startAccessingSecurityScopedResource()
            defer { 
                if accessing { url.stopAccessingSecurityScopedResource() } 
            }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                importedCards = parseCSV(content: content)
                
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
    
    private func parseCSV(content: String) -> [Card] {
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
    
    private func createDeck() {
        var newDeck = Deck(name: deckName)
        newDeck.cards = importedCards
        decks.append(newDeck)
        dismiss()
    }
}
