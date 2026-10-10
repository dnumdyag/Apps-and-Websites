import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Palette taken from the Figma Make design.
enum Theme {
    static let bgTop = Color(hex: 0x0A2417)
    static let bgMid = Color(hex: 0x044531)
    static let bgBottom = Color(hex: 0x021A0F)

    static let gold = Color(hex: 0xD4AF5F)
    static let goldDeep = Color(hex: 0xC2A14A)
    static let goldDark = Color(hex: 0xB89A4E)

    static let text = Color(hex: 0xF5F5F0)
    static let textSoft = Color(hex: 0xB8C4BA)
    static let textMuted = Color(hex: 0x8A9B8E)

    static let border = Color(hex: 0x2A5A48)
    static let card1 = Color(hex: 0x1A5542)
    static let card2 = Color(hex: 0x164A3B)
    static let card3 = Color(hex: 0x134C3B)
    static let chip = Color(hex: 0x1A4838)

    static let background = LinearGradient(
        colors: [bgTop, bgMid, bgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardFill = LinearGradient(
        colors: [card1.opacity(0.6), card2.opacity(0.65), card3.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldFill = LinearGradient(
        colors: [goldDeep.opacity(0.95), goldDark.opacity(0.95)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
