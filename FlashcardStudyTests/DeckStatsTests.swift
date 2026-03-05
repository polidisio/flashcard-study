import XCTest
@testable import FlashcardStudy

final class DeckStatsTests: XCTestCase {
    
    func testDeckStatsCreation() {
        let stats = DeckStats()
        XCTAssertEqual(stats.totalCards, 0)
        XCTAssertEqual(stats.masteredCards, 0)
        XCTAssertEqual(stats.averagePrecision, 0)
        XCTAssertEqual(stats.studyStreak, 0)
        XCTAssertNil(stats.lastStudyDate)
        XCTAssertEqual(stats.totalStudySessions, 0)
    }
    
    func testUpdateWithEmptyCardStats() {
        var stats = DeckStats()
        
        stats.update(with: [])
        
        XCTAssertEqual(stats.totalCards, 0)
        XCTAssertEqual(stats.masteredCards, 0)
        XCTAssertEqual(stats.averagePrecision, 0)
        XCTAssertEqual(stats.studyStreak, 1) // First study
        XCTAssertEqual(stats.totalStudySessions, 1)
    }
    
    func testUpdateWithCardStats() {
        var stats = DeckStats()
        
        var card1 = CardStats()
        card1.timesStudied = 10
        card1.timesCorrect = 8
        card1.level = 7 // mastered
        
        var card2 = CardStats()
        card2.timesStudied = 5
        card2.timesCorrect = 2
        card2.level = 3 // not mastered
        
        stats.update(with: [card1, card2])
        
        XCTAssertEqual(stats.totalCards, 2)
        XCTAssertEqual(stats.masteredCards, 1) // only card1 is mastered (level > 5)
        XCTAssertEqual(stats.averagePrecision, 60.0, accuracy: 0.01) // (80 + 40) / 2
        XCTAssertEqual(stats.studyStreak, 1)
        XCTAssertEqual(stats.totalStudySessions, 1)
    }
    
    func testStudyStreakConsecutiveDays() {
        var stats = DeckStats()
        
        // First study
        stats.update(with: [CardStats()])
        let firstDate = stats.lastStudyDate
        
        // Simulate next day
        stats.lastStudyDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        stats.update(with: [CardStats()])
        
        XCTAssertEqual(stats.studyStreak, 2)
        XCTAssertGreaterThan(stats.lastStudyDate!, firstDate ?? Date())
    }
    
    func testStudyStreakBroken() {
        var stats = DeckStats()
        
        // First study
        stats.update(with: [CardStats()])
        
        // Simulate more than 1 day passed
        stats.lastStudyDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
        
        stats.update(with: [CardStats()])
        
        XCTAssertEqual(stats.studyStreak, 1) // Streak resets
    }
    
    func testMasteredCardsCount() {
        var stats = DeckStats()
        
        var masteredCards: [CardStats] = []
        for i in 0..<5 {
            var card = CardStats()
            card.level = 6 + i // All mastered (level > 5)
            masteredCards.append(card)
        }
        
        var nonMasteredCards: [CardStats] = []
        for i in 0..<3 {
            var card = CardStats()
            card.level = i + 1 // Not mastered (level <= 5)
            nonMasteredCards.append(card)
        }
        
        let allCards = masteredCards + nonMasteredCards
        stats.update(with: allCards)
        
        XCTAssertEqual(stats.masteredCards, 5)
    }
    
    func testReset() {
        var stats = DeckStats()
        stats.totalCards = 10
        stats.masteredCards = 5
        stats.averagePrecision = 75.0
        stats.studyStreak = 7
        stats.lastStudyDate = Date()
        stats.totalStudySessions = 10
        
        stats.reset()
        
        XCTAssertEqual(stats.totalCards, 0)
        XCTAssertEqual(stats.masteredCards, 0)
        XCTAssertEqual(stats.averagePrecision, 0)
        XCTAssertEqual(stats.studyStreak, 0)
        XCTAssertNil(stats.lastStudyDate)
        XCTAssertEqual(stats.totalStudySessions, 0)
    }
    
    func testMultipleStudySessions() {
        var stats = DeckStats()
        
        stats.update(with: [CardStats()])
        stats.update(with: [CardStats()])
        stats.update(with: [CardStats()])
        
        XCTAssertEqual(stats.totalStudySessions, 3)
    }
}
