import SwiftUI

struct ContentView: View {
    @Bindable var deckStore: DeckStore
    @State private var showingAddDeck = false
    @State private var showingImport = false
    @State private var selectedDeckIndex: Int? = nil
    @State private var editingDeckIndex: Int? = nil
    @State private var editingDeckName: String = ""
    @State private var searchText: String = ""
    
    private var filteredDecks: [Deck] {
        if searchText.isEmpty {
            return Array(deckStore.decks)
        }
        return deckStore.decks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var totalCards: Int {
        deckStore.decks.reduce(0) { $0 + $1.cards.count }
    }
    
    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.90, blue: 0.98),
                    Color(red: 0.80, green: 0.86, blue: 0.96),
                    Color(red: 0.75, green: 0.82, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(Color.indigo.opacity(0.12))
                .frame(width: 350, height: 350)
                .blur(radius: 70)
                .offset(x: 150, y: 200)
            
            Circle()
                .fill(Color.cyan.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -150, y: 300)
        }
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .searchable(text: $searchText, prompt: Strings.ContentView.searchDecks)
                .background(backgroundView)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            HStack(spacing: 6) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.body)
                                Text(Strings.ContentView.myDecks)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            Text("\(deckStore.decks.count) \(Strings.ContentView.decksCards)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
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
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(filteredDecks.enumerated()), id: \.element.id) { index, deck in
                        deckCard(for: deck, at: index)
                    }
                }
                .padding()
            }
        }
    }
    
    private func deckCard(for deck: Deck, at index: Int) -> some View {
        Button {
            selectedDeckIndex = index
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(deckColor(deck.color))
                    .frame(width: 6, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(deck.cards.count) \(Strings.ContentView.cards)")
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
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(deckColor(deck.color).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                editingDeckIndex = index
                editingDeckName = deck.name
            } label: {
                Label(Strings.ContentView.rename, systemImage: "pencil")
            }
            Button(role: .destructive) {
                deckStore.deleteDeck(at: IndexSet(integer: index))
            } label: {
                Label(Strings.ContentView.delete, systemImage: "trash")
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
                Section(Strings.AddDeck.deckName) {
                    TextField(Strings.AddDeck.enterDeckName, text: $deckName)
                }
            }
            .navigationTitle(Strings.ContentView.rename)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.AddDeck.cancel) { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.AddDeck.save) { onSave() }
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
