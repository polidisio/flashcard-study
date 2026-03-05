import SwiftUI

@main
struct FlashcardStudyApp: App {
    @State private var deckStore = DeckStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(deckStore: deckStore)
                .tint(.blue)
                .preferredColorScheme(.light)
        }
    }
}
