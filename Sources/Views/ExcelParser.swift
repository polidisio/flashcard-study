import Foundation

struct ExcelParser {
    
    static func parse(url: URL) throws -> [[String]] {
        // iOS doesn't allow file system access, so we'll parse directly
        let accessing = url.startAccessingSecurityScopedResource()
        defer { 
            if accessing { url.stopAccessingSecurityScopedResource() } 
        }
        
        // Read file as binary data
        let data = try Data(contentsOf: url)
        
        // Check if it's a valid ZIP/XLSX file
        guard data.count > 2 else {
            throw NSError(domain: "ExcelParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "File too small"])
        }
        
        // Try to find XML content directly in the data
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ExcelParser", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not read file"])
        }
        
        // Look for shared strings and sheet data
        var result: [[String]] = []
        
        // Simple XML parsing - look for row and cell patterns
        let lines = content.components(separatedBy: .newlines)
        var currentRow: [String] = []
        
        for line in lines {
            // Check for row start
            if line.contains("<row ") || line.contains("<row>") {
                if !currentRow.isEmpty {
                    result.append(currentRow)
                    currentRow = []
                }
            }
            
            // Extract cell values
            if line.contains("<v>") || line.contains("<t>") {
                if let startRange = line.range(of: ">"),
                   let endRange = line.range(of: "</v>") {
                    let value = String(line[startRange.upperBound..<endRange.lowerBound])
                    currentRow.append(value)
                }
            }
        }
        
        if !currentRow.isEmpty {
            result.append(currentRow)
        }
        
        return result
    }
}
