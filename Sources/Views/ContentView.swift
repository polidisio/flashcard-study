import SwiftUI

struct ContentView: View {
    @Bindable var deckStore: DeckStore
    @State private var showingAddDeck = false
    @State private var showingImport = false
    @State private var selectedDeckIndex: Int? = nil
    @State private var editingDeckIndex: Int? = nil
    @State private var editingDeckName: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark 
                        ? [Color(uiColor: .systemBackground), Color.blue.opacity(0.15)] 
                        : [Color(uiColor: .systemBackground), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(deckStore.decks.enumerated()), id: \.element.id) { index, deck in
                            DeckCardView(
                                deck: deck,
                                onTap: { selectedDeckIndex = index },
                                onEdit: {
                                    editingDeckIndex = index
                                    editingDeckName = deck.name
                                },
                                onDelete: {
                                    deckStore.deleteDeck(at: IndexSet(integer: index))
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Decks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingImport = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(.blue)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
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

struct DeckCardView: View {
    let deck: Deck
    var onTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(deck.cards.count) cards")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EditDeckNameView: View {
    @Binding var deckName: String
    var onSave: () -> Void
    var onCancel: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
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
        .presentationBackground(.ultraThinMaterial)
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
