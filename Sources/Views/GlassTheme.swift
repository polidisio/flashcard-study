import SwiftUI

extension Color {
    static let glassBackground = Color("GlassBackground", bundle: nil)
    static let glassCard = Color("GlassCard", bundle: nil)
    static let glassAccent = Color.blue
    
    static let glassPrimary = LinearGradient(
        colors: [Color.blue, Color.blue.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassBackgroundLight = LinearGradient(
        colors: [Color.white, Color.blue.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glassBackgroundDark = LinearGradient(
        colors: [Color(white: 0.1), Color(white: 0.05), Color.blue.opacity(0.1)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static var adaptiveGlassBackground: Color {
        Color(uiColor: UIColor.systemBackground)
    }
    
    static var adaptiveGlassSecondary: Color {
        Color(uiColor: UIColor.secondarySystemBackground)
    }
    
    static var adaptiveGlassTertiary: Color {
        Color(uiColor: UIColor.tertiarySystemBackground)
    }
}

struct GlassStyle {
    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 10
    static let blurRadius: CGFloat = 20
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: GlassStyle.cardRadius))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct GlassButtonStyle: ButtonStyle {
    var accentColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(accentColor)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GlassSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle {
        GlassButtonStyle()
    }
    
    static func glass(accent color: Color) -> GlassButtonStyle {
        GlassButtonStyle(accentColor: color)
    }
}

extension ButtonStyle where Self == GlassSecondaryButtonStyle {
    static var glassSecondary: GlassSecondaryButtonStyle {
        GlassSecondaryButtonStyle()
    }
}
