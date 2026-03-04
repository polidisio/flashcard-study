import Foundation

struct ExcelParser {
    
    static func parse(url: URL) throws -> [[String]] {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { 
            if accessing { url.stopAccessingSecurityScopedResource() } 
        }
        
        // Read file data
        let data = try Data(contentsOf: url)
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ExcelParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not read file as text"])
        }
        
        // Simple parsing - look for shared strings and row data
        var result: [[String]] = []
        
        // Find all rows with data
        let rows = content.components(separatedBy: "<row ")
        
        for row in rows.dropFirst() {
            var rowData: [String] = []
            
            // Extract cell values
            let cells = row.components(separatedBy: "<c ")
            for cell in cells {
                // Look for inline string <is><t>
                if cell.contains("<is><t>") {
                    if let start = cell.range(of: "<is><t>"),
                       let end = cell.range(of: "</t></is>") {
                        let value = String(cell[start.upperBound..<end.lowerBound])
                        rowData.append(value)
                    }
                }
                // Look for value <v>
                else if cell.contains("<v>") {
                    if let start = cell.range(of: "<v>"),
                       let end = cell.range(of: "</v>") {
                        let value = String(cell[start.upperBound..<end.lowerBound])
                        rowData.append(value)
                    }
                }
            }
            
            if !rowData.isEmpty {
                result.append(rowData)
            }
        }
        
        return result
    }
}
