import XCTest
@testable import FlashcardStudy

final class CardStatsTests: XCTestCase {
    
    func testCardStatsCreation() {
        let stats = CardStats()
        XCTAssertEqual(stats.timesStudied, 0)
        XCTAssertEqual(stats.timesCorrect, 0)
        XCTAssertEqual(stats.timesIncorrect, 0)
        XCTAssertNil(stats.lastStudied)
        XCTAssertEqual(stats.level, 0)
        XCTAssertEqual(stats.precision, 0)
    }
    
    func testMarkStudiedCorrect() {
        var stats = CardStats()
        
        stats.markStudied(correct: true)
        
        XCTAssertEqual(stats.timesStudied, 1)
        XCTAssertEqual(stats.timesCorrect, 1)
        XCTAssertEqual(stats.timesIncorrect, 0)
        XCTAssertEqual(stats.level, 1)
        XCTAssertNotNil(stats.lastStudied)
        XCTAssertEqual(stats.precision, 100.0)
    }
    
    func testMarkStudiedIncorrect() {
        var stats = CardStats()
        
        stats.markStudied(correct: false)
        
        XCTAssertEqual(stats.timesStudied, 1)
        XCTAssertEqual(stats.timesCorrect, 0)
        XCTAssertEqual(stats.timesIncorrect, 1)
        XCTAssertEqual(stats.level, 1) // min level is 1, so from 0 it goes to 1
        XCTAssertNotNil(stats.lastStudied)
        XCTAssertEqual(stats.precision, 0.0)
    }
    
    func testPrecisionCalculation() {
        var stats = CardStats()
        
        stats.markStudied(correct: true)
        stats.markStudied(correct: true)
        stats.markStudied(correct: false)
        
        XCTAssertEqual(stats.timesStudied, 3)
        XCTAssertEqual(stats.timesCorrect, 2)
        XCTAssertEqual(stats.timesIncorrect, 1)
        XCTAssertEqual(stats.precision, 66.666666666666671, accuracy: 0.01)
    }
    
    func testLevelMaxValue() {
        var stats = CardStats()
        
        for _ in 0..<15 {
            stats.markStudied(correct: true)
        }
        
        XCTAssertEqual(stats.level, 10) // max level is 10
    }
    
    func testLevelMinValue() {
        var stats = CardStats()
        stats.level = 1
        
        for _ in 0..<15 {
            stats.markStudied(correct: false)
        }
        
        XCTAssertEqual(stats.level, 1) // min level is 1
    }
    
    func testReset() {
        var stats = CardStats()
        stats.timesStudied = 10
        stats.timesCorrect = 8
        stats.timesIncorrect = 2
        stats.level = 7
        stats.lastStudied = Date()
        
        stats.reset()
        
        XCTAssertEqual(stats.timesStudied, 0)
        XCTAssertEqual(stats.timesCorrect, 0)
        XCTAssertEqual(stats.timesIncorrect, 0)
        XCTAssertNil(stats.lastStudied)
        XCTAssertEqual(stats.level, 0)
    }
}
