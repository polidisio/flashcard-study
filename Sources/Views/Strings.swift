import SwiftUI

enum Strings {
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    enum ContentView {
        static var searchDecks: String { localized("Search decks") }
        static var myDecks: String { localized("My Decks") }
        static var decks: String { localized("decks") }
        static var decksCards: String { localized("decks • cards") }
        static var cards: String { localized("cards") }
        static var rename: String { localized("Rename") }
        static var delete: String { localized("Delete") }
    }
    
    enum AddDeck {
        static var deckName: String { localized("Deck Name") }
        static var enterDeckName: String { localized("Enter deck name") }
        static var color: String { localized("Color") }
        static var newDeck: String { localized("New Deck") }
        static var cancel: String { localized("Cancel") }
        static var save: String { localized("Save") }
    }
    
    enum StudyView {
        static var allCards: String { localized("All Cards") }
        static var dueToday: String { localized("Due Today") }
        static var studyMode: String { localized("Study Mode") }
        static var noCardsInDeck: String { localized("No Cards in Deck") }
        static var addFirstCard: String { localized("Add First Card") }
        static var done: String { localized("Done") }
        static var cardOf: String { localized("Card %d of %d") }
        static var editCard: String { localized("Edit Card") }
        static var deleteCard: String { localized("Delete Card") }
        static var tapToReveal: String { localized("Tap card to reveal answer") }
        static var addCard: String { localized("Add Card") }
        static var edit: String { localized("Edit") }
        static var statistics: String { localized("Statistics") }
        static var level: String { localized("Level") }
        static var precision: String { localized("Precision") }
        static var studied: String { localized("Studied") }
        static var correct: String { localized("Correct") }
        static var incorrect: String { localized("Incorrect") }
        static var frontQuestion: String { localized("Front (Question)") }
        static var backAnswer: String { localized("Back (Answer)") }
        static var enterQuestion: String { localized("Enter question") }
        static var enterAnswer: String { localized("Enter answer") }
        static var add: String { localized("Add") }
        static var playAudio: String { localized("Play Audio") }
        static var playing: String { localized("Playing...") }
    }
    
    enum StatsView {
        static var statistics: String { localized("Statistics") }
        static var summary: String { localized("Summary") }
        static var totalCards: String { localized("Total Cards") }
        static var mastered: String { localized("Mastered") }
        static var dueForReview: String { localized("Due for Review") }
        static var averagePrecision: String { localized("Average Precision") }
        static var currentStreak: String { localized("Current Streak") }
        static var longestStreak: String { localized("Longest Streak") }
        static var bestPrecision: String { localized("Best Precision") }
        static var resetStatistics: String { localized("Reset Statistics") }
        static var cancel: String { localized("Cancel") }
        static var reset: String { localized("Reset") }
        static var resetConfirmation: String { localized("Are you sure you want to reset all statistics for this deck? This action cannot be undone.") }
        static var cardStatistics: String { localized("Card Statistics") }
        static var days: String { localized("days") }
    }
    
    enum ImportView {
        static var importDecks: String { localized("Import Decks") }
        static var selectFile: String { localized("Select File") }
        static var importing: String { localized("Importing...") }
        static var success: String { localized("Import Successful") }
        static var successMessage: String { localized("Decks imported successfully.") }
        static var error: String { localized("Import Error") }
        static var invalidFile: String { localized("Invalid file format. Please select a valid file.") }
        static var cancel: String { localized("Cancel") }
        static var ok: String { localized("OK") }
    }
}
