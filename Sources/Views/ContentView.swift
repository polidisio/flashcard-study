import SwiftUI

struct ContentView: View {
    @State private var decks: [Deck] = []
    @State private var showingAddDeck = false
    @State private var selectedDeck: Deck?
    
    var body: some View {
        NavigationStack {
            DeckListView(decks: $decks, selectedDeck: $selectedDeck, showingAddDeck: $showingAddDeck)
                .navigationTitle("Decks")
                .sheet(isPresented: $showingAddDeck) {
                    AddDeckView(decks: $decks)
                }
                .sheet(item: $selectedDeck) { deck in
                    StudyView(deck: binding(for: deck) ?? $decks[0])
                }
        }
        .preferredColorScheme(.dark)
    }
    
    private func binding(for deck: Deck) -> Binding<Deck>? {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return nil }
        return $decks[index]
    }
}

struct DeckListView: View {
    @Binding var decks: [Deck]
    @Binding var selectedDeck: Deck?
    @Binding var showingAddDeck: Bool
    
    var body: some View {
        List {
            if decks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.gothicAccent)
                    Text("No Decks Yet")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Button("Create Your First Deck") {
                        showingAddDeck = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.gothicAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach($decks) { $deck in
                    DeckRowView(deck: $deck)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDeck = deck
                        }
                }
                .onDelete(perform: deleteDeck)
            }
        }
        .listStyle(.plain)
        .background(Color.gothicBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddDeck = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.gothicAccent)
                }
            }
        }
    }
    
    private func deleteDeck(at offsets: IndexSet) {
        decks.remove(atOffsets: offsets)
    }
}

struct DeckRowView: View {
    @Binding var deck: Deck
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(deck.name)
                .font(.headline)
                .foregroundStyle(Color.gothicText)
            Text("\(deck.cards.count) cards")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.gothicCard)
    }
}

struct AddDeckView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var deckName = ""
    @State private var cards: [Card] = []
    @State private var showingAddCard = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Deck Name", text: $deckName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                if !cards.isEmpty {
                    List {
                        ForEach(cards) { card in
                            VStack(alignment: .leading) {
                                Text(card.front)
                                    .font(.headline)
                                Text(card.back)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(height: 200)
                }
                
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add Card", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.gothicAccent)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newDeck = Deck(name: deckName, cards: cards)
                        decks.append(newDeck)
                        dismiss()
                    }
                    .disabled(deckName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(cards: $cards)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var cards: [Card]
    @State private var front = ""
    @State private var back = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Front (Question)") {
                    TextField("Enter question", text: $front, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Back (Answer)") {
                    TextField("Enter answer", text: $back, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let card = Card(front: front, back: back)
                        cards.append(card)
                        dismiss()
                    }
                    .disabled(front.isEmpty || back.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
