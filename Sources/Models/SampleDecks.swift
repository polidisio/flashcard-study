import Foundation

struct SampleDecks {
    
    static func createAllDecks() -> [Deck] {
        return [
            Deck(name: "Vocabulary", cards: vocabularyCards, color: "red"),
            Deck(name: "History", cards: historyCards, color: "blue"),
            Deck(name: "Science", cards: scienceCards, color: "green"),
            Deck(name: "Languages", cards: languagesCards, color: "purple"),
        ]
    }
    
    // MARK: - Vocabulary
    private static var vocabularyCards: [Card] {
        [
            Card(front: "Hello", back: "Hola"),
            Card(front: "Goodbye", back: "Adiós"),
            Card(front: "Thank you", back: "Gracias"),
            Card(front: "Please", back: "Por favor"),
            Card(front: "Sorry", back: "Lo siento"),
            Card(front: "Yes", back: "Sí"),
            Card(front: "No", back: "No"),
            Card(front: "Good morning", back: "Buenos días"),
            Card(front: "Good night", back: "Buenas noches"),
            Card(front: "How are you?", back: "¿Cómo estás?"),
        ]
    }
    
    // MARK: - History
    private static var historyCards: [Card] {
        [
            Card(front: "Who was Julius Caesar?", back: "Roman emperor and military leader"),
            Card(front: "When did World War II end?", back: "1945"),
            Card(front: "What was the French Revolution?", back: "Political upheaval in France (1789-1799)"),
            Card(front: "Who built the Pyramids?", back: "Ancient Egyptians"),
            Card(front: "When did Columbus reach America?", back: "1492"),
            Card(front: "What was the Berlin Wall?", back: "Symbol of Cold War division (1961-1989)"),
            Card(front: "Who was Napoleon?", back: "French military and political leader"),
            Card(front: "When did the Titanic sink?", back: "April 15, 1912"),
            Card(front: "What was the Renaissance?", back: "Cultural movement in Europe (14th-17th century)"),
            Card(front: "Who was Leonardo da Vinci?", back: "Italian polymath and artist"),
        ]
    }
    
    // MARK: - Science
    private static var scienceCards: [Card] {
        [
            Card(front: "What is photosynthesis?", back: "Process plants use to convert light to energy"),
            Card(front: "What is H2O?", back: "Water"),
            Card(front: "What is the speed of light?", back: "299,792 km/s"),
            Card(front: "What is gravity?", back: "Force that attracts bodies to Earth"),
            Card(front: "What is the largest planet?", back: "Jupiter"),
            Card(front: "What is DNA?", back: "Deoxyribonucleic acid - genetic material"),
            Card(front: "What is the chemical symbol for gold?", back: "Au"),
            Card(front: "What is the powerhouse of the cell?", back: "Mitochondria"),
            Card(front: "What is evolution?", back: "Change of species over time"),
            Card(front: "What is the atomic number of carbon?", back: "6"),
        ]
    }
    
    // MARK: - Languages
    private static var languagesCards: [Card] {
        [
            Card(front: "Bonjour", back: "Hello (French)"),
            Card(front: "Guten Tag", back: "Hello (German)"),
            Card(front: "Ciao", back: "Hello/Goodbye (Italian)"),
            Card(front: "Hola", back: "Hello (Spanish)"),
            Card(front: "Konnichiwa", back: "Hello (Japanese)"),
            Card(front: "Ni hao", back: "Hello (Chinese)"),
            Card(front: "Olá", back: "Hello (Portuguese)"),
            Card(front: "Ahlan", back: "Hello (Arabic)"),
            Card(front: "Privet", back: "Hello (Russian)"),
            Card(front: "Namaste", back: "Hello (Hindi)"),
        ]
    }
}
