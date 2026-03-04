import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var deckName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Enter deck name", text: $deckName)
                }
            }
            .navigationTitle("New Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !deckName.isEmpty {
                            decks.append(Deck(name: deckName))
                            dismiss()
                        }
                    }
                    .disabled(deckName.isEmpty)
                }
            }
        }
    }
}
