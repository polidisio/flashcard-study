import XCTest
@testable import FlashcardStudy

final class CSVParserTests: XCTestCase {
    
    func testBasicCSV() {
        let content = """
        front,back
        Question1,Answer1
        Question2,Answer2
        """
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards[0].front, "Question1")
        XCTAssertEqual(cards[0].back, "Answer1")
    }
    
    func testCSVWithSemicolonDelimiter() {
        let content = """
        front;back
        Question1;Answer1
        Question2;Answer2
        """
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards.count, 2)
    }
    
    func testCSVWithQuotedValues() {
        let content = """
        front,back
        "Question, with comma",Answer1
        Question2,"Answer, with comma"
        """
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards.count, 2)
    }
    
    func testCSVWithTabDelimiter() {
        let content = "front\tback\nQ1\tA1"
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards.count, 1)
    }
    
    func testCSVSkipsHeader() {
        let content = """
        front,back
        Question1,Answer1
        Question2,Answer2
        """
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards[0].front, "Question1")
    }
    
    func testEmptyLinesSkipped() {
        let content = """
        front,back
        
        Question1,Answer1
        
        Question2,Answer2
        """
        
        let cards = parseCSVContentTest(content)
        
        XCTAssertEqual(cards.count, 2)
    }
    
    private func parseCSVContentTest(_ content: String) -> [Card] {
        var cards: [Card] = []
        let lines = content.components(separatedBy: .newlines)
        
        var delimiter: Character = ","
        
        if let firstLine = lines.first {
            let semicolonCount = firstLine.filter { $0 == ";" }.count
            let commaCount = firstLine.filter { $0 == "," }.count
            let tabCount = firstLine.filter { $0 == "\t" }.count
            
            if semicolonCount > commaCount && semicolonCount >= tabCount {
                delimiter = ";"
            } else if tabCount > commaCount && tabCount > semicolonCount {
                delimiter = "\t"
            }
        }
        
        var start = 0
        if let first = lines.first?.lowercased(), first.contains("front") || first.contains("question") {
            start = 1
        }
        
        for line in lines.dropFirst(start) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            let parts = parseCSVLineTest(trimmed, delimiter: delimiter)
            
            if parts.count >= 2 {
                var front = parts[0].trimmingCharacters(in: .whitespaces)
                var back = parts[1].trimmingCharacters(in: .whitespaces)
                
                front = front.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                back = back.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        return cards
    }
    
    private func parseCSVLineTest(_ line: String, delimiter: Character) -> [String] {
        var result: [String] = []
        var current = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == delimiter && !insideQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result
    }
}
