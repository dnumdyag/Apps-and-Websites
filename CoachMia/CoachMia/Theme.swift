import SwiftUI
import CoreText

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

/// Palette and type taken from the "Coach Mia App" design canvas.
enum Theme {
    // Grounds
    static let background = Color(hex: 0xEBF2ED)
    static let surface = Color.white
    static let divider = Color(hex: 0xD8E1DA)
    static let track = Color(hex: 0xCBD5CE)
    static let pill = Color(hex: 0xDCE6DF)

    // Ink
    static let ink = Color(hex: 0x10241D)
    static let muted = Color(hex: 0x55615B)
    static let faint = Color(hex: 0x6B7670)
    static let outline = Color(hex: 0xB4BCB6)

    // Greens
    static let green = Color(hex: 0x1B5E4A)
    static let greenDeep = Color(hex: 0x0E3F31)
    static let greenTrack = Color(hex: 0x4A8570)
    static let onGreen = Color(hex: 0xF7F3E8)
    static let onGreenMuted = Color(hex: 0xCFE0D7)
    static let online = Color(hex: 0x2FA36B)

    // Golds
    static let goldText = Color(hex: 0x7A5C17)
    static let goldOnGreen = Color(hex: 0xEBD08A)
    static let goldInk = Color(hex: 0x14261E)
    static let goldCardInk = Color(hex: 0x3D2F0A)
    static let goldDot = Color(hex: 0xC99A3C)

    // Alerts
    static let red = Color(hex: 0xA8402A)
    static let liveDot = Color(hex: 0xD9634A)

    static let goldFill = LinearGradient(colors: [Color(hex: 0xE8D192), Color(hex: 0xD4B066)],
                                         startPoint: .top, endPoint: .bottom)
    static let goldCardFill = LinearGradient(colors: [Color(hex: 0xF1E0AC), Color(hex: 0xD9B66E)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)

    // MARK: Type

    enum Weight { case regular, medium, semibold, bold }

    /// Cormorant Garamond, used for headings.
    static func serif(_ size: CGFloat, _ weight: Weight = .semibold, italic: Bool = false) -> Font {
        let name: String
        switch (weight, italic) {
        case (.bold, false): name = "CormorantGaramond-Bold"
        case (.semibold, false): name = "CormorantGaramond-SemiBold"
        case (_, false): name = "CormorantGaramond-Medium"
        case (.semibold, true), (.bold, true): name = "CormorantGaramondItalic-SemiBoldItalic"
        case (_, true): name = "CormorantGaramondItalic-MediumItalic"
        }
        return .custom(name, size: size)
    }

    /// Montserrat, used for body text and buttons.
    static func sans(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        switch weight {
        case .regular: return .custom("Montserrat-Regular", size: size)
        case .medium: return .custom("Montserrat-Medium", size: size)
        case .semibold: return .custom("Montserrat-SemiBold", size: size)
        case .bold: return .custom("Montserrat-Bold", size: size)
        }
    }

    /// Mrs Saint Delafield, used for the "Coach Mia" logotype.
    static func script(_ size: CGFloat) -> Font {
        .custom("MrsSaintDelafield-Regular", size: size)
    }

    /// Registers the bundled .ttf files so the custom fonts above resolve.
    static func registerFonts() {
        let urls = (Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [])
            + (Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") ?? [])
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
