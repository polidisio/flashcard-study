import Foundation

struct CardStats: Codable, Equatable {
    var timesStudied: Int = 0
    var timesCorrect: Int = 0
    var timesIncorrect: Int = 0
    var lastStudied: Date?
    var level: Int = 0
    
    var precision: Double {
        guard timesStudied > 0 else { return 0 }
        return Double(timesCorrect) / Double(timesStudied) * 100
    }
    
    mutating func markStudied(correct: Bool) {
        timesStudied += 1
        if correct {
            timesCorrect += 1
            level = min(10, level + 1)
        } else {
            timesIncorrect += 1
            level = max(1, level - 1)
        }
        lastStudied = Date()
    }
    
    mutating func reset() {
        timesStudied = 0
        timesCorrect = 0
        timesIncorrect = 0
        lastStudied = nil
        level = 0
    }
}

struct DeckStats: Codable, Equatable {
    var totalCards: Int = 0
    var masteredCards: Int = 0
    var averagePrecision: Double = 0
    var studyStreak: Int = 0
    var lastStudyDate: Date?
    var totalStudySessions: Int = 0
    
    mutating func update(with cardStats: [CardStats]) {
        totalCards = cardStats.count
        masteredCards = cardStats.filter { $0.level > 5 }.count
        
        let totalPrecision = cardStats.reduce(0.0) { $0 + $1.precision }
        averagePrecision = totalPrecision > 0 ? totalPrecision / Double(cardStats.count) : 0
        
        let now = Date()
        if let lastDate = lastStudyDate {
            let calendar = Calendar.current
            let daysDiff = calendar.dateComponents([.day], from: lastDate, to: now).day ?? 0
            if daysDiff == 1 {
                studyStreak += 1
            } else if daysDiff > 1 {
                studyStreak = 1
            }
        } else {
            studyStreak = 1
        }
        
        lastStudyDate = now
        totalStudySessions += 1
    }
    
    mutating func reset() {
        totalCards = 0
        masteredCards = 0
        averagePrecision = 0
        studyStreak = 0
        lastStudyDate = nil
        totalStudySessions = 0
    }
}
