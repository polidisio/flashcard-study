import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation

extension UTType {
    static var xlsx: UTType {
        UTType(filenameExtension: "xlsx") ?? .data
    }
}

enum ImportFormat: String, CaseIterable {
    case csv = "CSV"
    case excel = "Excel"
}

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    var deckStore: DeckStore
    @State private var deckName = ""
    @State private var importedCards: [Card] = []
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var selectedFormat: ImportFormat = .csv
    
    private var fileTypes: [UTType] {
        switch selectedFormat {
        case .csv:
            return [.commaSeparatedText, .plainText]
        case .excel:
            return [.xlsx]
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Deck Name") {
                    TextField("Enter deck name", text: $deckName)
                }
                
                Section("Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ImportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button("Select File") {
                        showingFilePicker = true
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section("Preview") {
                    if importedCards.isEmpty {
                        Text("No cards loaded")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(importedCards.count) cards ready")
                            .foregroundStyle(.green)
                        
                        ForEach(importedCards.prefix(3)) { card in
                            VStack(alignment: .leading) {
                                Text(card.front).font(.caption).bold()
                                Text(card.back).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        importDeck()
                    }
                    .disabled(deckName.isEmpty || importedCards.isEmpty)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: fileTypes,
                allowsMultipleSelection: false
            ) { result in
                handleFile(result)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                switch selectedFormat {
                case .csv:
                    importedCards = try parseCSV(url: url)
                case .excel:
                    importedCards = try parseExcel(url: url)
                }
                if importedCards.isEmpty {
                    errorMessage = "No cards found"
                    showingError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func parseCSV(url: URL) throws -> [Card] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        return parseCSVContent(content)
    }
    
    private func parseCSVContent(_ content: String) -> [Card] {
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
            
            let parts = parseCSVLine(trimmed, delimiter: delimiter)
            
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
    
    private func parseCSVLine(_ line: String, delimiter: Character) -> [String] {
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
    
    private func parseExcel(url: URL) throws -> [Card] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        guard let archive = Archive(url: url, accessMode: .read) else {
            throw NSError(domain: "Parse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot read Excel file"])
        }
        
        var sharedStrings: [String] = []
        
        if let sharedStringsEntry = archive["xl/sharedStrings.xml"] {
            var sharedStringsData = Data()
            _ = try archive.extract(sharedStringsEntry) { data in
                sharedStringsData.append(data)
            }
            if let content = String(data: sharedStringsData, encoding: .utf8) {
                sharedStrings = parseSharedStrings(content)
            }
        }
        
        guard let sheetEntry = archive["xl/worksheets/sheet1.xml"] else {
            throw NSError(domain: "Parse", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot find sheet in Excel file"])
        }
        
        var sheetData = Data()
        _ = try archive.extract(sheetEntry) { data in
            sheetData.append(data)
        }
        
        guard let content = String(data: sheetData, encoding: .utf8) else {
            throw NSError(domain: "Parse", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot read sheet content"])
        }
        
        let cards = parseSheetXML(content, sharedStrings: sharedStrings)
        
        if cards.isEmpty {
            throw NSError(domain: "Parse", code: 4, userInfo: [NSLocalizedDescriptionKey: "No cards found. Ensure Excel has 'front' and 'back' columns."])
        }
        
        return cards
    }
    
    private func parseSharedStrings(_ content: String) -> [String] {
        var strings: [String] = []
        let pattern = "<t>(.*?)</t>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return strings }
        
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex.matches(in: content, options: [], range: range)
        
        for match in matches {
            if let matchRange = Range(match.range(at: 1), in: content) {
                strings.append(String(content[matchRange]))
            }
        }
        
        return strings
    }
    
    private func parseSheetXML(_ content: String, sharedStrings: [String]) -> [Card] {
        var cards: [Card] = []
        
        let rowPattern = "<row[^>]*>(.*?)</row>"
        guard let rowRegex = try? NSRegularExpression(pattern: rowPattern, options: [.dotMatchesLineSeparators]) else {
            return cards
        }
        
        let range = NSRange(content.startIndex..., in: content)
        let rowMatches = rowRegex.matches(in: content, options: [], range: range)
        
        for (index, rowMatch) in rowMatches.enumerated() {
            guard let rowRange = Range(rowMatch.range(at: 1), in: content) else { continue }
            let rowContent = String(content[rowRange])
            
            var rowData: [String] = []
            
            let cellPattern = "<c[^>]*>(<is><t>(.*?)</t></is>|(<v>(.*?)</v>))?</c>"
            guard let cellRegex = try? NSRegularExpression(pattern: cellPattern, options: [.dotMatchesLineSeparators]) else { continue }
            let cellRange = NSRange(rowContent.startIndex..., in: rowContent)
            
            let cellMatches = cellRegex.matches(in: rowContent, options: [], range: cellRange)
            
            for cellMatch in cellMatches {
                if let tRange = Range(cellMatch.range(at: 2), in: rowContent) {
                    rowData.append(String(rowContent[tRange]))
                } else if let vRange = Range(cellMatch.range(at: 4), in: rowContent) {
                    let valueStr = String(rowContent[vRange])
                    if let valueIndex = Int(valueStr), valueIndex < sharedStrings.count {
                        rowData.append(sharedStrings[valueIndex])
                    } else {
                        rowData.append(valueStr)
                    }
                }
            }
            
            if index == 0 && rowData.first?.lowercased().contains("front") == true {
                continue
            }
            
            if rowData.count >= 2 {
                let front = rowData[0].trimmingCharacters(in: .whitespaces)
                let back = rowData[1].trimmingCharacters(in: .whitespaces)
                if !front.isEmpty && !back.isEmpty {
                    cards.append(Card(front: front, back: back))
                }
            }
        }
        
        return cards
    }
    
    private func importDeck() {
        let newDeck = Deck(name: deckName, cards: importedCards)
        deckStore.addDeck(newDeck)
        dismiss()
    }
}
