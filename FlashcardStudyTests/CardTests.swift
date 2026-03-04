import XCTest
@testable import FlashcardStudy

final class CardTests: XCTestCase {
    
    func testCardCreation() {
        let card = Card(front: "Question", back: "Answer")
        XCTAssertEqual(card.front, "Question")
        XCTAssertEqual(card.back, "Answer")
        XCTAssertNotNil(card.id)
    }
    
    func testCardEquality() {
        let id = UUID()
        let card1 = Card(id: id, front: "Q1", back: "A1")
        let card2 = Card(id: id, front: "Q1", back: "A1")
        XCTAssertEqual(card1, card2)
    }
    
    func testDeckCreation() {
        let deck = Deck(name: "Test Deck")
        XCTAssertEqual(deck.name, "Test Deck")
        XCTAssertTrue(deck.cards.isEmpty)
        XCTAssertNotNil(deck.id)
        XCTAssertNotNil(deck.createdAt)
    }
    
    func testDeckWithCards() {
        let cards = [
            Card(front: "Q1", back: "A1"),
            Card(front: "Q2", back: "A2")
        ]
        let deck = Deck(name: "Test", cards: cards)
        XCTAssertEqual(deck.cards.count, 2)
    }
}
