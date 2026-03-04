import SwiftUI

struct ContentView: View {
    @Bindable var deckStore: DeckStore
    @State private var showingAddDeck = false
    @State private var showingImport = false
    @State private var selectedDeckIndex: Int? = nil
    @State private var editingDeckIndex: Int? = nil
    @State private var editingDeckName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(deckStore.decks.enumerated()), id: \.element.id) { index, deck in
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
                    .contextMenu {
                        Button {
                            editingDeckIndex = index
                            editingDeckName = deck.name
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                    }
                }
                .onDelete { offsets in
                    deckStore.deleteDeck(at: offsets)
                }
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
                AddDeckView(deckStore: deckStore)
            }
            .sheet(isPresented: $showingImport) {
                ImportView(deckStore: deckStore)
            }
            .sheet(item: Binding(
                get: { selectedDeckIndex.map { IndexItem(index: $0) } },
                set: { selectedDeckIndex = $0?.index }
            )) { item in
                if item.index < deckStore.decks.count {
                    StudyView(deck: deckStore.decks[item.index], deckStore: deckStore)
                }
            }
            .sheet(item: Binding(
                get: { editingDeckIndex.map { EditDeckItem(index: $0, name: deckStore.decks[$0].name) } },
                set: { editingDeckIndex = $0?.index }
            )) { item in
                EditDeckNameView(
                    deckName: $editingDeckName,
                    onSave: {
                        if let index = editingDeckIndex {
                            deckStore.renameDeck(at: index, to: editingDeckName)
                        }
                        editingDeckIndex = nil
                    },
                    onCancel: {
                        editingDeckIndex = nil
                    }
                )
            }
        }
    }
}

struct EditDeckNameView: View {
    @Binding var deckName: String
    var onSave: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Enter deck name", text: $deckName)
                }
            }
            .navigationTitle("Rename Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .disabled(deckName.isEmpty)
                }
            }
        }
    }
}

struct EditDeckItem: Identifiable {
    let id = UUID()
    let index: Int
    let name: String
}

struct IndexItem: Identifiable {
    let id = UUID()
    let index: Int
}

#Preview {
    ContentView(deckStore: DeckStore())
}
