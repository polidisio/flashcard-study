import Foundation

enum ReviewQuality: Int, CaseIterable {
    case again = 0
    case hard = 1
    case good = 2
    case easy = 3
    
    var description: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
    
    var color: String {
        switch self {
        case .again: return "red"
        case .hard: return "orange"
        case .good: return "green"
        case .easy: return "blue"
        }
    }
}

struct SpacedRepetition {
    static func calculateNextReview(currentProgress: CardProgress, quality: ReviewQuality) -> CardProgress {
        var progress = currentProgress
        let q = Double(quality.rawValue)
        
        if quality == .again {
            progress.repetitions = 0
            progress.interval = 1
        } else {
            if progress.repetitions == 0 {
                progress.interval = 1
            } else if progress.repetitions == 1 {
                progress.interval = 6
            } else {
                progress.interval = Int(Double(progress.interval) * progress.easeFactor)
            }
            progress.repetitions += 1
        }
        
        let newEaseFactor = progress.easeFactor + (0.1 - (3.0 - q) * (0.08 + (3.0 - q) * 0.02))
        progress.easeFactor = max(1.3, newEaseFactor)
        
        progress.nextReviewDate = Calendar.current.date(byAdding: .day, value: progress.interval, to: Date()) ?? Date()
        
        return progress
    }
    
    static func cardsToReview(from cards: [Card], progress: [UUID: CardProgress]) -> [Card] {
        let now = Date()
        return cards.filter { card in
            if let cardProgress = progress[card.id] {
                return cardProgress.nextReviewDate <= now
            }
            return true
        }
    }
    
    static func sortByPriority(cards: [Card], progress: [UUID: CardProgress]) -> [Card] {
        let now = Date()
        return cards.sorted { card1, card2 in
            let date1 = progress[card1.id]?.nextReviewDate ?? Date.distantPast
            let date2 = progress[card2.id]?.nextReviewDate ?? Date.distantPast
            
            if date1 <= now && date2 > now {
                return true
            } else if date1 > now && date2 <= now {
                return false
            } else if date1 <= now && date2 <= now {
                return date1 < date2
            }
            return date1 < date2
        }
    }
}
