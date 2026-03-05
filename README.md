# ThinkDeck Study

A modern flashcard study app for iOS and iPadOS, featuring spaced repetition learning, glassmorphism design, and multilingual support.

## Features

- 📚 **Spaced Repetition System (SRS)** - Smart algorithm to optimize your learning
- 🎴 **Deck Management** - Create, edit, and organize flashcard decks
- 📱 **iPhone & iPad Support** - Native support for all iOS devices
- 🌐 **Multilingual** - Available in English, Spanish, French, and German
- 🎨 **Modern Design** - Glassmorphism UI with customizable deck colors
- 📊 **Statistics** - Track your progress and mastery levels
- 📥 **Import** - Import decks from CSV/Excel files
- 🔄 **Local Storage** - All data stored locally on your device

## Screenshots

The app features a beautiful light gradient background with glass-effect cards in various colors.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/polidisio/flashcard-study.git
   cd flashcard-study
   ```

2. Install dependencies (if needed):
   ```bash
   brew install xcodegen
   ```

3. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

4. Open in Xcode:
   ```bash
   open ThinkDeckStudy.xcodeproj
   ```

5. Select your development team in Xcode (Signing & Capabilities)

6. Build and run on simulator or device

## Project Structure

```
ThinkDeckStudy/
├── Sources/
│   ├── App/
│   │   └── FlashcardStudyApp.swift       # App entry point
│   ├── Models/
│   │   ├── Card.swift                     # Flashcard model
│   │   ├── Deck.swift                     # Deck model
│   │   ├── DeckStore.swift                # Data management
│   │   ├── SpacedRepetition.swift         # SRS algorithm
│   │   └── ...                            # Other models
│   ├── Views/
│   │   ├── ContentView.swift              # Main screen
│   │   ├── StudyView.swift                # Study mode
│   │   ├── AddDeckView.swift              # Add deck screen
│   │   ├── StatsView.swift                # Statistics
│   │   └── ...                            # Other views
│   ├── en.lproj/                          # English translations
│   ├── es.lproj/                          # Spanish translations
│   ├── fr.lproj/                          # French translations
│   └── de.lproj/                          # German translations
└── FlashcardStudyTests/                   # Unit tests
```

## Technologies

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming
- **ZIPFoundation** - Excel file parsing
- **XCTest** - Unit testing

## Supported Languages

| Language | Code |
|----------|------|
| English | en |
| Spanish | es |
| French | fr |
| German | de |

The app automatically detects your device language and displays the appropriate translation.

## App Store

This app is configured for App Store submission with:
- Hardened Runtime enabled
- dSYM generation for crash reports
- Proper App Icon set (all required sizes)
- Multilingual support (EN, ES, FR, DE)

## License

Private - All rights reserved

## Author

Created with ❤️ using SwiftUI
