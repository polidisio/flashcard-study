import SwiftUI

struct StatsView: View {
    let deck: Deck
    @Environment(\.dismiss) var dismiss
    var deckStore: DeckStore
    @State private var showingResetAlert = false
    @State private var refreshKey = 0
    
    private var deckStats: DeckStats {
        refreshKey
        return deckStore.getDeckStats(for: deck.id)
    }
    
    private var cardStats: [UUID: CardStats] {
        refreshKey
        return deckStore.getAllCardStats(for: deck.id)
    }
    
    private var sortedCards: [Card] {
        refreshKey
        return deck.cards.sorted { card1, card2 in
            let stats1 = cardStats[card1.id] ?? CardStats()
            let stats2 = cardStats[card2.id] ?? CardStats()
            return stats1.timesStudied > stats2.timesStudied
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    
                    streakSection
                    
                    cardsListSection
                }
                .padding()
            }
            .background(Color.gothicBackground)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        refreshKey += 1
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Reset Statistics", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    deckStore.resetStats(for: deck.id)
                    refreshKey += 1
                }
            } message: {
                Text("Are you sure you want to reset all statistics for this deck? This action cannot be undone.")
            }
            .onAppear {
                refreshKey += 1
            }
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(Color.gothicText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                StatCard(title: "Total Cards", value: "\(deckStats.totalCards)", color: .blue)
                StatCard(title: "Mastered", value: "\(deckStats.masteredCards)", color: .green)
            }
            
            HStack(spacing: 12) {
                StatCard(title: "Avg. Precision", value: String(format: "%.1f%%", deckStats.averagePrecision), color: precisionColor)
                StatCard(title: "Sessions", value: "\(deckStats.totalStudySessions)", color: .purple)
            }
        }
    }
    
    private var precisionColor: Color {
        switch deckStats.averagePrecision {
        case 0..<50: return .red
        case 50..<75: return .orange
        default: return .green
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: 12) {
            Text("Study Streak")
                .font(.headline)
                .foregroundStyle(Color.gothicText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "flame.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading) {
                    Text("\(deckStats.studyStreak) days")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.gothicText)
                    
                    if let lastDate = deckStats.lastStudyDate {
                        Text("Last studied: \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gothicCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var cardsListSection: some View {
        VStack(spacing: 12) {
            Text("Card Statistics")
                .font(.headline)
                .foregroundStyle(Color.gothicText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(sortedCards) { card in
                CardStatsRow(card: card, stats: cardStats[card.id] ?? CardStats())
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CardStatsRow: View {
    let card: Card
    let stats: CardStats
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.front)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.gothicText)
                    .lineLimit(1)
                
                Text(card.back)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Lv\(stats.level)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(levelColor.opacity(0.2))
                    .foregroundStyle(levelColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text(String(format: "%.0f%%", stats.precision))
                    .font(.caption)
                    .foregroundStyle(precisionColor)
                
                Text("\(stats.timesStudied)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gothicCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var levelColor: Color {
        switch stats.level {
        case 0...3: return .red
        case 4...6: return .orange
        case 7...9: return .green
        default: return .blue
        }
    }
    
    private var precisionColor: Color {
        switch stats.precision {
        case 0..<50: return .red
        case 50..<75: return .orange
        default: return .green
        }
    }
}
