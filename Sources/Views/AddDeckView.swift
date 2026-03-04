import SwiftUI
import UniformTypeIdentifiers

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var deckName = ""
    @State private var importedCards: [Card] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Enter deck name", text: $deckName)
                }
                
                Section("Cards") {
                    if importedCards.isEmpty {
                        Text("No cards imported")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(importedCards.count) cards imported")
                            .foregroundStyle(.green)
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
                isPresented: Binding(
                    get: { false },
                    set: { if $0 { pickFile() } }
                ),
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            )
        }
    }
    
    private func saveDeck() {
        let newDeck = Deck(name: deckName, cards: importedCards)
        decks.append(newDeck)
        dismiss()
    }
    
    private func pickFile() {
        // This is a placeholder - file importer needs to be triggered differently
    }
}

#Preview {
    AddDeckView(decks: .constant([]))
}
