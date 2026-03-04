import SwiftUI
import UniformTypeIdentifiers
import Foundation

extension UTType {
    static var xlsx: UTType {
        UTType(filenameExtension: "xlsx") ?? .data
    }
}

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var decks: [Deck]
    @State private var importedCards: [Card] = []
    @State private var selectedDeckIndex: Int = 0
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingDeckPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importedCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.gothicAccent)
                        Text("Import Cards")
                            .font(.title2)
                        Text("Import flashcards from CSV or Excel files.\nFormat: front,back (first row is header)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showingDeckPicker = true
                        } label: {
                            Label("Select File to Import", systemImage: "doc.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.gothicAccent)
                        .fileImporter(
                            isPresented: $showingDeckPicker,
                            allowedContentTypes: [.commaSeparatedText, .plainText, .xlsx],
                            allowsMultipleSelection: false
                        ) { result in
                            handleFileSelection(result)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Text("Imported \(importedCards.count) cards")
                            .font(.headline)
                            .foregroundStyle(Color.gothicAccent)
                        
                        List {
                            ForEach(importedCards) { card in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.front)
                                        .font(.headline)
                                        .foregroundStyle(Color.gothicText)
                                    Text(card.back)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 300)
                        
                        HStack {
                            Button("Cancel") {
                                importedCards = []
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Add to Deck") {
                                addCardsToDeck()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.gothicAccent)
                            .disabled(decks.isEmpty)
                        }
                    }
                    .padding()
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Import Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Unable to access file"
                showingError = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            let fileExtension = url.pathExtension.lowercased()
            
            do {
                if fileExtension == "xlsx" {
                    importedCards = try parseExcel(url: url)
                } else {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    importedCards = parseCSV(content: content)
                }
                
                if importedCards.isEmpty {
                    errorMessage = "No valid cards found in file"
                    showingError = true
                }
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
                showingError = true
            }
            
        case .failure(let error):
            errorMessage = "File selection failed: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func parseCSV(content: String) -> [Card] {
        var cards: [Card] = []
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index == 0 && line.lowercased().contains("front") && line.lowercased().contains("back") {
                continue
            }
            
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            let parts = parseCSVLine(trimmedLine)
            if parts.count >= 2 {
                let card = Card(front: parts[0], back: parts[1])
                cards.append(card)
            }
        }
        
        return cards
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
    
    private func parseExcel(url: URL) throws -> [Card] {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", url.path, "-d", tempDir.path]
        try process.run()
        process.waitUntilExit()
        
        let sharedStringsPath = tempDir.appendingPathComponent("xl/sharedStrings.xml")
        var sharedStrings: [String] = []
        
        if FileManager.default.fileExists(atPath: sharedStringsPath.path) {
            let sharedStringsData = try Data(contentsOf: sharedStringsPath)
            if let sharedStringsXML = String(data: sharedStringsData, encoding: .utf8) {
                sharedStrings = parseSharedStrings(sharedStringsXML)
            }
        }
        
        let sheetPath = tempDir.appendingPathComponent("xl/worksheets/sheet1.xml")
        guard FileManager.default.fileExists(atPath: sheetPath.path) else {
            throw NSError(domain: "ImportView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find sheet1.xml in Excel file"])
        }
        
        let sheetData = try Data(contentsOf: sheetPath)
        guard let sheetXML = String(data: sheetData, encoding: .utf8) else {
            throw NSError(domain: "ImportView", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not read sheet XML"])
        }
        
        return parseSheetXML(sheetXML, sharedStrings: sharedStrings)
    }
    
    private func parseSharedStrings(_ xml: String) -> [String] {
        var strings: [String] = []
        var currentString = ""
        var inT = false
        
        var chars = Array(xml)
        var i = 0
        while i < chars.count {
            if i + 3 < chars.count && chars[i] == "<" && chars[i+1] == "t" && chars[i+2] == ">" {
                inT = true
                i += 3
                continue
            }
            if inT && chars[i] == "<" && i + 4 < chars.count && String(chars[i..<i+4]) == "</t>" {
                strings.append(currentString)
                currentString = ""
                inT = false
                i += 4
                continue
            }
            if inT {
                currentString.append(chars[i])
            }
            i += 1
        }
        
        return strings
    }
    
    private func parseSheetXML(_ xml: String, sharedStrings: [String]) -> [Card] {
        var cards: [Card] = []
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentCell = ""
        var inV = false
        var inT = false
        var cellRef = ""
        var lastCol = -1
        
        var chars = Array(xml)
        var i = 0
        while i < chars.count {
            if i + 8 < chars.count && String(chars[i..<i+9]) == "<row r=\"" {
                if !currentRow.isEmpty && currentRow.count >= 2 {
                    rows.append(currentRow)
                }
                currentRow = []
                lastCol = -1
                i += 9
                continue
            }
            
            if i + 2 < chars.count && chars[i] == "<" && chars[i+1] == "c" {
                var j = i + 2
                cellRef = ""
                while j < chars.count && chars[j] != ">" && chars[j] != " " {
                    cellRef.append(chars[j])
                    j += 1
                }
                
                let col = columnIndexFromRef(cellRef)
                while currentRow.count <= col {
                    currentRow.append("")
                }
                i = j
                continue
            }
            
            if i + 2 < chars.count && String(chars[i..<i+3]) == "<v>" {
                inV = true
                currentCell = ""
                i += 3
                continue
            }
            if inV && chars[i] == "<" && i + 1 < chars.count && chars[i+1] == "/" {
                inV = false
                if let col = cellRef.isEmpty ? nil : columnIndexFromRef(cellRef) {
                    if col < currentRow.count {
                        if let intVal = Int(currentCell), intVal < sharedStrings.count {
                            currentRow[col] = sharedStrings[intVal]
                        } else {
                            currentRow[col] = currentCell
                        }
                    }
                }
                i += 1
                continue
            }
            
            if i + 2 < chars.count && String(chars[i..<i+3]) == "<t>" {
                inT = true
                currentCell = ""
                i += 3
                continue
            }
            if inT && chars[i] == "<" && i + 3 < chars.count && String(chars[i..<i+4]) == "</t>" {
                inT = false
                if let col = cellRef.isEmpty ? nil : columnIndexFromRef(cellRef) {
                    if col < currentRow.count {
                        currentRow[col] = currentCell
                    }
                }
                i += 4
                continue
            }
            
            if inV || inT {
                currentCell.append(chars[i])
            }
            i += 1
        }
        
        if !currentRow.isEmpty && currentRow.count >= 2 {
            rows.append(currentRow)
        }
        
        for (index, row) in rows.enumerated() {
            if index == 0 && row[0].lowercased().contains("front") && row[1].lowercased().contains("back") {
                continue
            }
            if row.count >= 2 && !row[0].isEmpty && !row[1].isEmpty {
                cards.append(Card(front: row[0], back: row[1]))
            }
        }
        
        return cards
    }
    
    private func columnIndexFromRef(_ ref: String) -> Int {
        var col = 0
        for char in ref {
            if char.isLetter {
                col = col * 26 + Int(char.asciiValue! - 64)
            } else {
                break
            }
        }
        return col - 1
    }
    
    private func addCardsToDeck() {
        guard !decks.isEmpty else { return }
        
        let targetDeckIndex = selectedDeckIndex % decks.count
        decks[targetDeckIndex].cards.append(contentsOf: importedCards)
        importedCards = []
        dismiss()
    }
}

#Preview {
    ImportView(decks: .constant([Deck(name: "Test Deck")]))
}
