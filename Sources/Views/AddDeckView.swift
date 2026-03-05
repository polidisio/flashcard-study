import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    var deckStore: DeckStore
    @State private var deckName = ""
    @State private var selectedColor = "blue"
    
    init(deckStore: DeckStore) {
        self.deckStore = deckStore
    }
    
    private var deckColors: [(String, Color)] = [
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("mint", Color(red: 0.0, green: 0.8, blue: 0.6)),
        ("teal", .teal),
        ("blue", .blue),
        ("indigo", .indigo),
        ("purple", .purple),
        ("pink", .pink),
        ("brown", .brown)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.AddDeck.deckName) {
                    TextField(Strings.AddDeck.enterDeckName, text: $deckName)
                }
                
                Section(Strings.AddDeck.color) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(deckColors, id: \.0) { colorName, color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == colorName ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = colorName
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(Strings.AddDeck.newDeck)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.AddDeck.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.AddDeck.save) {
                        if !deckName.isEmpty {
                            deckStore.addDeck(Deck(name: deckName, color: selectedColor))
                            dismiss()
                        }
                    }
                    .disabled(deckName.isEmpty)
                }
            }
        }
    }
}
