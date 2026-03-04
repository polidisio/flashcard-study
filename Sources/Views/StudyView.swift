import SwiftUI

struct StudyView: View {
    @Binding var deck: Deck
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    
    var body: some View {
        NavigationStack {
            if deck.cards.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.on.rectangle.slash")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.gothicAccent)
                    Text("No Cards in Deck")
                        .font(.title2)
                    Text("Add some cards to start studying")
                        .foregroundStyle(.secondary)
                }
            } else {
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
                        
                        HStack(spacing: 40) {
                            Button {
                                previousCard()
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 50))
                            }
                            .disabled(currentIndex == 0)
                            .foregroundStyle(currentIndex == 0 ? Color.gray : Color.gothicAccent)
                            
                            Button {
                                nextCard()
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 50))
                            }
                            .disabled(currentIndex == deck.cards.count - 1)
                            .foregroundStyle(currentIndex == deck.cards.count - 1 ? Color.gray : Color.gothicAccent)
                        }
                        .padding(.top, 20)
                        
                        Text("Tap card to flip")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gothicBackground)
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
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
        .frame(width: 300, height: 400)
    }
}

#Preview {
    StudyView(deck: .constant(Deck(name: "Test Deck", cards: [
        Card(front: "Question 1", back: "Answer 1"),
        Card(front: "Question 2", back: "Answer 2")
    ])))
}
