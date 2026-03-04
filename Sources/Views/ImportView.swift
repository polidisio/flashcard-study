import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var importedCards: [Card] = []
    @State private var showingDeckPicker = false
    @State private var selectedDeckIndex = 0
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importedCards.isEmpty {
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
                        showingDeckPicker = true
                    } label: {
                        Label("Select CSV File", systemImage: "doc.text")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.gothicAccent)
                } else {
                    VStack(spacing: 16) {
                        Text("Imported \(importedCards.count) cards")
                            .font(.headline)
                            .foregroundStyle(Color.gothicAccent)
                        
                        List {
                            ForEach(importedCards) { card in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.front)
                                        .font(.headline)
                                        .foregroundStyle(Color.gothicText)
                                    Text(card.back)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 300)
                        
                        HStack {
                            Button("Cancel") {
                                importedCards = []
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Add to Deck") {
                                addCardsToDeck()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.gothicAccent)
                        }
                    }
                }
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
                isPresented: $showingDeckPicker,
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
            .sheet(isPresented: $showingDeckPicker) { }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            
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
    
    private func addCardsToDeck() {
        guard !decks.isEmpty else { return }
        
        let targetDeckIndex = selectedDeckIndex % decks.count
        decks[targetDeckIndex].cards.append(contentsOf: importedCards)
        importedCards = []
        dismiss()
    }
}

#Preview {
    ImportView(decks: .constant([Deck(name: "Test Deck")]))
}
