import SwiftUI

struct StudyView: View {
    let deck: Deck
    @Environment(\.dismiss) var dismiss
    @Environment(DeckStore.self) private var deckStore
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var showingAddCard = false
    @State private var editingCard: Card?
    @State private var newFront = ""
    @State private var newBack = ""
    @State private var editingFront = ""
    @State private var editingBack = ""
    @State private var editingCardId: UUID?
    @State private var studyMode: StudyMode = .all
    
    enum StudyMode: String, CaseIterable {
        case all = "All Cards"
        case dueToday = "Due Today"
    }
    
    private var currentDeck: Deck? {
        deckStore.decks.first { $0.id == deck.id }
    }
    
    private var cards: [Card] {
        currentDeck?.cards ?? []
    }
    
    private var studyCards: [Card] {
        switch studyMode {
        case .all:
            return cards
        case .dueToday:
            return deckStore.getCardsForReview(for: deck.id)
        }
    }
    
    private var currentCard: Card? {
        guard currentIndex < studyCards.count else { return nil }
        return studyCards[currentIndex]
    }
    
    var body: some View {
        NavigationStack {
            if cards.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    Picker("Study Mode", selection: $studyMode) {
                        ForEach(StudyMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    cardView
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            addCardSheet
        }
        .sheet(item: Binding(
                get: { editingCard },
                set: { editingCard = $0 }
            )) { card in
            editCardSheet(card: card)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 60))
                .foregroundStyle(Color.gothicAccent)
            Text("No Cards in Deck")
                .font(.title2)
            Button("Add First Card") {
                showingAddCard = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.gothicAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gothicBackground)
        .navigationTitle(deck.name)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCard = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private var cardView: some View {
        VStack(spacing: 30) {
            Text("Card \(currentIndex + 1) of \(studyCards.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let card = currentCard {
                CardFlipView(
                    front: card.front,
                    back: card.back,
                    isFlipped: $isFlipped,
                    rotation: $rotation
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isFlipped.toggle()
                        rotation += 180
                    }
                }
                .contextMenu {
                    Button {
                        editingCard = card
                    } label: {
                        Label("Edit Card", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        deleteCard(card: card)
                    } label: {
                        Label("Delete Card", systemImage: "trash")
                    }
                }
            }
            
            if isFlipped {
                reviewButtons
            } else {
                Text("Tap card to reveal answer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            navigationButtons
            
            HStack {
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                
                if currentIndex < cards.count {
                    Button {
                        editingCard = cards[currentIndex]
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gothicBackground)
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCard = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private var reviewButtons: some View {
        HStack(spacing: 12) {
            ForEach(ReviewQuality.allCases, id: \.rawValue) { quality in
                Button {
                    rateCard(quality: quality)
                } label: {
                    Text(quality.description)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(buttonColor(for: quality))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func buttonColor(for quality: ReviewQuality) -> Color {
        switch quality {
        case .again: return .red
        case .hard: return .orange
        case .good: return .green
        case .easy: return .blue
        }
    }
    
    private func rateCard(quality: ReviewQuality) {
        guard let card = currentCard else { return }
        
        let progress = deckStore.getProgress(for: deck.id).getProgress(for: card.id)
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: quality)
        deckStore.updateCardProgress(newProgress, for: deck.id)
        
        moveToNextCard()
    }
    
    private func moveToNextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFlipped = false
            rotation = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < studyCards.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 40) {
            Button { previousCard() } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 50))
            }
            .disabled(currentIndex == 0)
            .foregroundStyle(currentIndex == 0 ? Color.gray : Color.gothicAccent)
            
            Button { nextCard() } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 50))
            }
            .disabled(currentIndex >= studyCards.count - 1)
            .foregroundStyle(currentIndex >= studyCards.count - 1 ? Color.gray : Color.gothicAccent)
        }
    }
    
    private var addCardSheet: some View {
        NavigationStack {
            Form {
                Section("Front (Question)") {
                    TextField("Enter question", text: $newFront, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Back (Answer)") {
                    TextField("Enter answer", text: $newBack, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newFront = ""
                        newBack = ""
                        showingAddCard = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCard()
                    }
                    .disabled(newFront.isEmpty || newBack.isEmpty)
                }
            }
        }
    }
    
    private func editCardSheet(card: Card) -> some View {
        NavigationStack {
            Form {
                Section("Front (Question)") {
                    TextField("Enter question", text: $editingFront, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Back (Answer)") {
                    TextField("Enter answer", text: $editingBack, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        if let cardId = editingCardId {
                            saveEditedCard(cardId: cardId)
                        }
                        editingCard = nil
                        editingCardId = nil
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
                        deleteCard(card: card)
                        editingCard = nil
                        editingCardId = nil
                    }
                    .foregroundStyle(.red)
                }
            }
            .onAppear {
                editingFront = card.front
                editingBack = card.back
                editingCardId = card.id
            }
        }
    }
    
    private func saveEditedCard(cardId: UUID) {
        guard let deckIndex = deckStore.decks.firstIndex(where: { $0.id == deck.id }) else { return }
        if let cardIndex = deckStore.decks[deckIndex].cards.firstIndex(where: { $0.id == cardId }) {
            deckStore.decks[deckIndex].cards[cardIndex].front = editingFront
            deckStore.decks[deckIndex].cards[cardIndex].back = editingBack
            deckStore.save()
        }
    }
    
    private func addCard() {
        guard let index = deckStore.decks.firstIndex(where: { $0.id == deck.id }) else { return }
        let newCard = Card(front: newFront, back: newBack)
        deckStore.decks[index].cards.append(newCard)
        deckStore.save()
        newFront = ""
        newBack = ""
        showingAddCard = false
    }
    
    private func updateCard(_ card: Card, front: String? = nil, back: String? = nil) {
        guard let deckIndex = deckStore.decks.firstIndex(where: { $0.id == deck.id }) else { return }
        if let cardIndex = deckStore.decks[deckIndex].cards.firstIndex(where: { $0.id == card.id }) {
            if let front = front {
                deckStore.decks[deckIndex].cards[cardIndex].front = front
            }
            if let back = back {
                deckStore.decks[deckIndex].cards[cardIndex].back = back
            }
            deckStore.save()
        }
    }
    
    private func deleteCard(card: Card) {
        guard let deckIndex = deckStore.decks.firstIndex(where: { $0.id == deck.id }) else { return }
        if let index = deckStore.decks[deckIndex].cards.firstIndex(where: { $0.id == card.id }) {
            deckStore.decks[deckIndex].cards.remove(at: index)
            deckStore.save()
            if currentIndex >= deckStore.decks[deckIndex].cards.count && currentIndex > 0 {
                currentIndex = deckStore.decks[deckIndex].cards.count - 1
            }
        }
    }
    
    private func deleteCard(at index: Int) {
        guard let deckIndex = deckStore.decks.firstIndex(where: { $0.id == deck.id }) else { return }
        deckStore.decks[deckIndex].cards.remove(at: index)
        deckStore.save()
        if currentIndex >= deckStore.decks[deckIndex].cards.count && currentIndex > 0 {
            currentIndex = deckStore.decks[deckIndex].cards.count - 1
        }
    }
    
    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFlipped = false
            rotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < studyCards.count - 1 {
                currentIndex += 1
            }
        }
    }
    
    private func previousCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFlipped = false
            rotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
}

struct CardFlipView: View {
    let front: String
    let back: String
    @Binding var isFlipped: Bool
    @Binding var rotation: Double
    
    var body: some View {
        ZStack {
            CardFace(text: front, isBack: false)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            
            CardFace(text: back, isBack: true)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(rotation + 180), axis: (x: 0, y: 1, z: 0))
        }
    }
}

struct CardFace: View {
    let text: String
    let isBack: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isBack ? Color.gothicCardBack : Color.gothicCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gothicBorder, lineWidth: 3)
                )
            
            Text(text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gothicText)
                .padding()
        }
        .frame(width: 280, height: 350)
    }
}

#Preview {
    StudyView(deck: Deck(name: "Test", cards: [
        Card(front: "Q1", back: "A1"),
        Card(front: "Q2", back: "A2")
    ]))
}
