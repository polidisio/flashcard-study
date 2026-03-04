import XCTest
@testable import FlashcardStudy

final class SpacedRepetitionTests: XCTestCase {
    
    func testSM2AgainQuality() {
        var progress = CardProgress(cardId: UUID())
        progress.repetitions = 3
        progress.interval = 10
        progress.easeFactor = 2.5
        
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: .again)
        
        XCTAssertEqual(newProgress.repetitions, 0)
        XCTAssertEqual(newProgress.interval, 1)
    }
    
    func testSM2GoodQuality() {
        var progress = CardProgress(cardId: UUID())
        progress.repetitions = 0
        progress.interval = 0
        progress.easeFactor = 2.5
        
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: .good)
        
        XCTAssertEqual(newProgress.repetitions, 1)
        XCTAssertEqual(newProgress.interval, 1)
    }
    
    func testSM2EasyQuality() {
        var progress = CardProgress(cardId: UUID())
        progress.repetitions = 1
        progress.interval = 6
        progress.easeFactor = 2.5
        
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: .easy)
        
        XCTAssertEqual(newProgress.repetitions, 2)
        XCTAssertEqual(newProgress.interval, Int(6 * 2.5))
    }
    
    func testEaseFactorNeverBelowMinimum() {
        var progress = CardProgress(cardId: UUID())
        progress.easeFactor = 1.3
        
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: .again)
        
        XCTAssertGreaterThanOrEqual(newProgress.easeFactor, 1.3)
    }
    
    func testNextReviewDateIsFuture() {
        let progress = CardProgress(cardId: UUID())
        
        let newProgress = SpacedRepetition.calculateNextReview(currentProgress: progress, quality: .good)
        
        XCTAssertGreaterThan(newProgress.nextReviewDate, Date())
    }
    
    func testCardsToReview() {
        let cards = [
            Card(front: "Q1", back: "A1"),
            Card(front: "Q2", back: "A2"),
            Card(front: "Q3", back: "A3")
        ]
        
        var progress: [UUID: CardProgress] = [:]
        progress[cards[0].id] = CardProgress(cardId: cards[0].id)
        progress[cards[0].id]?.nextReviewDate = Date().addingTimeInterval(-86400)
        progress[cards[1].id] = CardProgress(cardId: cards[1].id)
        progress[cards[1].id]?.nextReviewDate = Date().addingTimeInterval(86400)
        
        let toReview = SpacedRepetition.cardsToReview(from: cards, progress: progress)
        
        XCTAssertEqual(toReview.count, 1)
        XCTAssertEqual(toReview[0].front, "Q1")
    }
}
