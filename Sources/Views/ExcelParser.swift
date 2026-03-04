import Foundation

struct ExcelParser {
    
    static func parse(url: URL) throws -> [[String]] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { 
            if accessing { url.stopAccessingSecurityScopedResource() } 
        }
        
        // Excel files are ZIP archives - we need to extract and read XML
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        // Use Process to unzip (available on iOS)
        let task = Foundation.Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-o", url.path, "-d", tempDir.path]
        
        // Since Process might not work, try alternative: use FileManager to copy and read as zip
        try FileManager.default.copyItem(at: url, to: tempDir.appendingPathComponent("temp.xlsx"))
        
        // Use NSZipFile if available, or simple XML parsing
        return try parseExcelXML(in: tempDir)
    }
    
    private static func parseExcelXML(in directory: URL) throws -> [[String]] {
        let fileManager = FileManager.default
        
        // Try to find sheet1.xml
        let sheetPath = directory.appendingPathComponent("xl/worksheets/sheet1.xml")
        
        guard fileManager.fileExists(atPath: sheetPath.path) else {
            // Try alternative path
            let altPath = directory.appendingPathComponent("temp.xlsx")
            if fileManager.fileExists(atPath: altPath.path) {
                return try parseXLSXDirect(fileURL: altPath)
            }
            throw NSError(domain: "ExcelParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find sheet"])
        }
        
        let data = try Data(contentsOf: sheetPath)
        guard let xml = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ExcelParser", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not read XML"])
        }
        
        return parseSheetXML(xml)
    }
    
    private static func parseXLSXDirect(fileURL: URL) throws -> [[String]] {
        // Try using basic XML parsing on the raw file
        let data = try Data(contentsOf: fileURL)
        
        // Look for shared strings first
        var sharedStrings: [String] = []
        let stringsPath = fileURL.deletingLastPathComponent().appendingPathComponent("xl/sharedStrings.xml")
        if let stringsData = try? Data(contentsOf: stringsPath),
           let stringsXML = String(data: stringsData, encoding: .utf8) {
            sharedStrings = extractStringsFromXML(stringsXML)
        }
        
        // Parse sheet
        let sheetPath = fileURL.deletingLastPathComponent().appendingPathComponent("xl/worksheets/sheet1.xml")
        if let sheetData = try? Data(contentsOf: sheetPath),
           let sheetXML = String(data: sheetData, encoding: .utf8) {
            return parseSheetXMLWithStrings(sheetXML, sharedStrings: sharedStrings)
        }
        
        return []
    }
    
    private static func extractStringsFromXML(_ xml: String) -> [String] {
        var strings: [String] = []
        var inT = false
        var current = ""
        
        let chars = Array(xml)
        var i = 0
        while i < chars.count {
            if i + 2 < chars.count && chars[i] == "<" && chars[i+1] == "t" && chars[i+2] == ">" {
                inT = true
                i += 3
                continue
            }
            if inT && i + 3 < chars.count && chars[i] == "<" && chars[i+1] == "/" && chars[i+2] == "t" && chars[i+3] == ">" {
                strings.append(current)
                current = ""
                inT = false
                i += 4
                continue
            }
            if inT {
                current.append(chars[i])
            }
            i += 1
        }
        return strings
    }
    
    private static func parseSheetXML(_ xml: String) -> [[String]] {
        return parseSheetXMLWithStrings(xml, sharedStrings: [])
    }
    
    private static func parseSheetXMLWithStrings(_ xml: String, sharedStrings: [String]) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentCell = ""
        var inV = false
        var inT = false
        var cellType = ""
        
        let chars = Array(xml)
        var i = 0
        var rowNum = 0
        
        while i < chars.count {
            // Check for row start
            if i + 5 < chars.count {
                let slice = String(chars[i..<min(i+6, chars.count)])
                if slice.hasPrefix("<row ") || slice.hasPrefix("<row>") {
                    if !currentRow.isEmpty && !currentRow.allSatisfy({ $0.isEmpty }) {
                        rows.append(currentRow)
                    }
                    currentRow = []
                    rowNum += 1
                    i += 5
                    continue
                }
            }
            
            // Check for cell
            if i + 2 < chars.count && chars[i] == "<" && chars[i+1] == "c" {
                currentCell = ""
                cellType = "str"
                var j = i + 2
                while j < chars.count && chars[j] != ">" && chars[j] != " " {
                    if chars[j] == "t" && j + 1 < chars.count && chars[j+1] == "=" {
                        j += 2
                        while j < chars.count && chars[j] != " " && chars[j] != ">" {
                            cellType = String(chars[j])
                            j += 1
                        }
                    }
                    j += 1
                }
                i = j
                continue
            }
            
            // Check for value
            if i + 2 < chars.count && String(chars[i..<i+3]) == "<v>" {
                inV = true
                currentCell = ""
                i += 3
                continue
            }
            if inV && chars[i] == "<" && i + 1 < chars.count && chars[i+1] == "/" {
                inV = false
                // Add cell value
                if let intVal = Int(currentCell), intVal < sharedStrings.count {
                    currentRow.append(sharedStrings[intVal])
                } else {
                    currentRow.append(currentCell)
                }
                currentCell = ""
                i += 2
                continue
            }
            
            // Check for inline string
            if i + 2 < chars.count && String(chars[i..<i+3]) == "<t>" {
                inT = true
                currentCell = ""
                i += 3
                continue
            }
            if inT && i + 3 < chars.count && String(chars[i..<i+4]) == "</t>" {
                inT = false
                currentRow.append(currentCell)
                currentCell = ""
                i += 4
                continue
            }
            
            if inV || inT {
                currentCell.append(chars[i])
            }
            i += 1
        }
        
        if !currentRow.isEmpty && !currentRow.allSatisfy({ $0.isEmpty }) {
            rows.append(currentRow)
        }
        
        return rows
    }
}
