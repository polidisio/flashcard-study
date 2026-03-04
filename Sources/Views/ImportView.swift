import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var importedCards: [Card] = []
    @State private var showingFilePicker = false
    @State private var selectedDeckIndex = 0
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var newDeckName = ""
    @State private var showingNewDeckSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.gothicAccent)
                
                Text("Import Cards")
                    .font(.title2)
                
                Text("Import flashcards from CSV files.\nFormat: front,back (first row is header)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingFilePicker = true
                } label: {
                    Label("Select CSV File", systemImage: "doc.text")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.gothicAccent)
                
                if !importedCards.isEmpty {
                    Divider()
                    
                    Text("Imported \(importedCards.count) cards")
                        .font(.headline)
                        .foregroundStyle(Color.gothicAccent)
                    
                    List(importedCards) { card in
                        VStack(alignment: .leading) {
                            Text(card.front)
                                .font(.headline)
                            Text(card.back)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 200)
                    
                    TextField("New deck name", text: $newDeckName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("Create Deck with Cards") {
                        if !newDeckName.isEmpty {
                            var newDeck = Deck(name: newDeckName)
                            newDeck.cards = importedCards
                            decks.append(newDeck)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.gothicAccent)
                    .disabled(newDeckName.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gothicBackground)
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
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
                if accessing { 
                    url.stopAccessingSecurityScopedResource() 
                } 
            }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                importedCards = parseCSV(content: content)
                
                if importedCards.isEmpty {
                    errorMessage = "No valid cards found in file"
                    showingError = true
                }
            } catch {
                errorMessage = "Error reading file: \(error.localizedDescription)"
                showingError = true
            }
        case .failure(let error):
            errorMessage = "Error selecting file: \(error.localizedDescription)"
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
            
            let fields = parseCSVLine(line)
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
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }
}

#Preview {
    ImportView(decks: .constant([Deck(name: "Test")]))
}
