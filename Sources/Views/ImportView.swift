import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var importedCards: [Card] = []
    @State private var selectedDeckIndex: Int = 0
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingDeckPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importedCards.isEmpty {
                    VStack(spacing: 16) {
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
                            Label("Select File to Import", systemImage: "doc.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.gothicAccent)
                        .fileImporter(
                            isPresented: $showingDeckPicker,
                            allowedContentTypes: [.commaSeparatedText, .plainText],
                            allowsMultipleSelection: false
                        ) { result in
                            handleFileSelection(result)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
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
                            
                            Spacer()
                            
                            Button("Add to Deck") {
                                addCardsToDeck()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.gothicAccent)
                            .disabled(decks.isEmpty)
                        }
                    }
                    .padding()
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Import Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Unable to access file"
                showingError = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                importedCards = parseCSV(content: content)
                if importedCards.isEmpty {
                    errorMessage = "No valid cards found in file"
                    showingError = true
                }
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
                showingError = true
            }
            
        case .failure(let error):
            errorMessage = "File selection failed: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func parseCSV(content: String) -> [Card] {
        var cards: [Card] = []
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index == 0 && line.lowercased().contains("front") && line.lowercased().contains("back") {
                continue
            }
            
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            let parts = parseCSVLine(trimmedLine)
            if parts.count >= 2 {
                let card = Card(front: parts[0], back: parts[1])
                cards.append(card)
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
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        
        result.append(current.trimmingCharacters(in: .whitespaces))
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
