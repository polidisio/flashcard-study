import SwiftUI

struct ContentView: View {
    @State private var decks: [Deck] = []
    @State private var showingAddDeck = false
    @State private var showingImport = false
    @State private var selectedDeckIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(decks.enumerated()), id: \.element.id) { index, deck in
                    Button {
                        selectedDeckIndex = index
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(deck.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.gothicText)
                                Text("\(deck.cards.count) cards")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.gothicCard)
                }
                .onDelete(perform: deleteDeck)
            }
            .listStyle(.plain)
            .background(Color.gothicBackground)
            .navigationTitle("Decks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingImport = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(Color.gothicAccent)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.gothicAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                AddDeckView(decks: $decks)
            }
            .sheet(isPresented: $showingImport) {
                ImportView(decks: $decks)
            }
            .sheet(item: Binding(
                get: { selectedDeckIndex.map { IndexItem(index: $0) } },
                set: { selectedDeckIndex = $0?.index }
            )) { item in
                if item.index < decks.count {
                    StudyView(deck: $decks[item.index])
                }
            }
            .onAppear {
                if decks.isEmpty {
                    decks = SampleDecks.createAllDecks()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func deleteDeck(at offsets: IndexSet) {
        decks.remove(atOffsets: offsets)
    }
}

struct IndexItem: Identifiable {
    let id = UUID()
    let index: Int
}

#Preview {
    ContentView()
}
