import SwiftUI

struct StudyView: View {
    @Binding var deck: Deck
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var showingAddCard = false
    @State private var editingCard: Card?
    @State private var newFront = ""
    @State private var newBack = ""
    
    var body: some View {
        NavigationStack {
            if deck.cards.isEmpty {
                emptyStateView
            } else {
                cardView
            }
        }
        .preferredColorScheme(.dark)
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
            Text("Card \(currentIndex + 1) of \(deck.cards.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if currentIndex < deck.cards.count {
                CardFlipView(
                    front: deck.cards[currentIndex].front,
                    back: deck.cards[currentIndex].back,
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
                        editingCard = deck.cards[currentIndex]
                    } label: {
                        Label("Edit Card", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        deleteCard(at: currentIndex)
                    } label: {
                        Label("Delete Card", systemImage: "trash")
                    }
                }
            }
            
            navigationButtons
            
            HStack {
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                
                if currentIndex < deck.cards.count {
                    Button {
                        editingCard = deck.cards[currentIndex]
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 10)
            
            Text("Tap card to flip")
                .font(.caption)
                .foregroundStyle(.secondary)
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
            .disabled(currentIndex >= deck.cards.count - 1)
            .foregroundStyle(currentIndex >= deck.cards.count - 1 ? Color.gray : Color.gothicAccent)
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
                    TextField("Enter question", text: Binding(
                        get: { card.front },
                        set: { updateCard(card, front: $0) }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }
                Section("Back (Answer)") {
                    TextField("Enter answer", text: Binding(
                        get: { card.back },
                        set: { updateCard(card, back: $0) }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        editingCard = nil
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
                        deleteCard(card: card)
                        editingCard = nil
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
    
    private func addCard() {
        let newCard = Card(front: newFront, back: newBack)
        deck.cards.append(newCard)
        newFront = ""
        newBack = ""
        showingAddCard = false
    }
    
    private func updateCard(_ card: Card, front: String? = nil, back: String? = nil) {
        if let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
            if let front = front {
                deck.cards[index].front = front
            }
            if let back = back {
                deck.cards[index].back = back
            }
        }
    }
    
    private func deleteCard(card: Card) {
        if let index = deck.cards.firstIndex(where: { $0.id == card.id }) {
            deck.cards.remove(at: index)
            if currentIndex >= deck.cards.count && currentIndex > 0 {
                currentIndex = deck.cards.count - 1
            }
        }
    }
    
    private func deleteCard(at index: Int) {
        deck.cards.remove(at: index)
        if currentIndex >= deck.cards.count && currentIndex > 0 {
            currentIndex = deck.cards.count - 1
        }
    }
    
    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFlipped = false
            rotation = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentIndex < deck.cards.count - 1 {
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
    StudyView(deck: .constant(Deck(name: "Test", cards: [
        Card(front: "Q1", back: "A1"),
        Card(front: "Q2", back: "A2")
    ])))
}
