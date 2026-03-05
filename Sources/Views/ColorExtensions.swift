import SwiftUI

func deckColor(_ colorName: String) -> Color {
    switch colorName {
    case "red": return .red
    case "orange": return .orange
    case "yellow": return .yellow
    case "green": return .green
    case "mint": return Color(red: 0.0, green: 0.8, blue: 0.6)
    case "teal": return .teal
    case "blue": return .blue
    case "indigo": return .indigo
    case "purple": return .purple
    case "pink": return .pink
    case "brown": return .brown
    default: return .blue
    }
}
