import SwiftUI

// MARK: - Cards

extension View {
    /// White rounded card.
    func whiteCard(padding: CGFloat = 20, radius: CGFloat = 22) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Deep green feature card with a soft green shadow.
    func greenCard(padding: CGFloat = 22) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Theme.onGreen)
            .background(Theme.green, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Theme.green.opacity(0.3), radius: 16, y: 16)
    }

    /// Gold gradient card used for membership.
    func goldCard(padding: CGFloat = 24, radius: CGFloat = 26) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Theme.goldInk)
            .background(Theme.goldCardFill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Mint screen background.
    func screenBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }
}

// MARK: - Liquid Glass

/// True when the app can draw Apple's Liquid Glass: built with Xcode 26 or later and running on iOS 26 or later.
var hasLiquidGlass: Bool {
    #if compiler(>=6.2)
    if #available(iOS 26.0, *) { return true }
    #endif
    return false
}

extension View {
    /// Apple's Liquid Glass in `shape` on iOS 26 and later. Older systems get `fallback` instead.
    @ViewBuilder
    func liquidGlass<S: Shape, F: View>(in shape: S, tint: Color? = nil, interactive: Bool = false,
                                        @ViewBuilder otherwise fallback: (Self) -> F) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect((tint.map { Glass.regular.tint($0) } ?? .regular).interactive(interactive), in: shape)
        } else {
            fallback(self)
        }
        #else
        fallback(self)
        #endif
    }
}

/// Groups glass views so they render together and blend as they move (iOS 26 and later).
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat? = nil
    @ViewBuilder let content: Content

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}

// MARK: - Buttons

/// Gold gradient pill. The primary call to action.
struct GoldButtonStyle: ButtonStyle {
    var height: CGFloat = 54
    var fontSize: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.sans(fontSize, .bold))
            .foregroundStyle(Theme.goldInk)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(Theme.goldFill, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

/// Green outline pill. Secondary actions like "Book", "Join", "Reserve".
struct OutlineButtonStyle: ButtonStyle {
    var fullWidth = false
    var height: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.sans(14, .semibold))
            .foregroundStyle(Theme.green)
            .padding(.horizontal, 18)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: height)
            .overlay(Capsule().stroke(Theme.green, lineWidth: 1.5))
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Dark green pill used on gold cards.
struct DarkButtonStyle: ButtonStyle {
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.sans(15, .bold))
            .foregroundStyle(Theme.onGreen)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: fullWidth ? 52 : 44)
            .background(Theme.greenDeep, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// White chip with a grey outline; turns green when selected.
struct ChipButtonStyle: ButtonStyle {
    var selected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.sans(13.5, .medium))
            .foregroundStyle(selected ? Theme.onGreen : Theme.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(selected ? Theme.green : Theme.surface, in: Capsule())
            .overlay(Capsule().stroke(selected ? Theme.green : Theme.outline, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// MARK: - Text

/// Big serif title with an optional gold italic ending, e.g. "Your *journey*".
struct ScreenTitle: View {
    let text: String
    var accent: String? = nil
    var size: CGFloat = 40

    var body: some View {
        accentText
            .font(Theme.serif(size, .medium))
            .foregroundColor(Theme.ink)
            .lineSpacing(-2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var accentText: Text {
        guard let accent else { return Text(text) }
        return Text(text) + Text(accent).font(Theme.serif(size, .medium, italic: true)).foregroundColor(Theme.goldText)
    }
}

struct ScreenHeader: View {
    let title: String
    var accent: String? = nil
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScreenTitle(text: title, accent: accent)
            if let subtitle {
                Text(subtitle)
                    .font(Theme.sans(15))
                    .foregroundStyle(Theme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionLabel: View {
    let text: String
    var color: Color = Theme.muted

    init(_ text: String, color: Color = Theme.muted) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(Theme.sans(11, .semibold))
            .tracking(2)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Small pieces

/// Dark translucent badge laid over photos ("3 spots left").
struct PhotoBadge: View {
    let text: String
    var dot: Color? = nil
    var color: Color = .white

    var body: some View {
        HStack(spacing: 7) {
            if let dot {
                Circle().fill(dot).frame(width: 7, height: 7)
            }
            Text(text)
        }
        .font(Theme.sans(12.5, .semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .liquidGlass(in: Capsule(), tint: Color(hex: 0x081813, opacity: 0.55)) {
            $0.background(Color(hex: 0x081813, opacity: 0.78), in: Capsule())
        }
    }
}

/// Thin progress line.
struct ProgressLine: View {
    let value: Double
    var track: Color = Theme.divider
    var fill: Color = Theme.green
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule().fill(fill)
                    .frame(width: geo.size.width * max(0, min(1, value)))
            }
        }
        .frame(height: height)
    }
}

/// Gold circle with an arrow, used on tappable cards.
struct GoldArrow: View {
    var size: CGFloat = 42

    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(Theme.goldInk)
            .frame(width: size, height: size)
            .background(Theme.goldFill, in: Circle())
    }
}

/// Green outlined circle with an arrow.
struct OutlineArrow: View {
    var size: CGFloat = 38

    var body: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(Theme.green)
            .frame(width: size, height: size)
            .overlay(Circle().stroke(Theme.green, lineWidth: 1.5))
    }
}

/// Round photo, e.g. Mia's avatar.
struct RoundPhoto: View {
    let name: String
    var size: CGFloat = 42

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

/// The user's avatar inside a gold ring: their photo if set, else their initial.
struct UserAvatar: View {
    @EnvironmentObject var state: AppState
    var size: CGFloat = 50

    var body: some View {
        ZStack {
            Circle().fill(Theme.goldFill)
            Group {
                if let data = state.profile.avatarData, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Text(String(state.firstName.prefix(1)).uppercased())
                        .font(Theme.serif(size * 0.45, .semibold))
                        .foregroundStyle(Theme.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.surface)
                }
            }
            .frame(width: size - 4, height: size - 4)
            .clipShape(Circle())
            .overlay(Circle().stroke(Theme.background, lineWidth: size > 80 ? 3 : 2))
        }
        .frame(width: size, height: size)
    }
}

/// Simple wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(widest, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

/// Lets us pick between two button styles with a ternary.
struct AnyButtonStyle: ButtonStyle {
    private let make: (ButtonStyleConfiguration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        make = { AnyView(style.makeBody(configuration: $0)) }
    }

    func makeBody(configuration: Configuration) -> some View {
        make(configuration)
    }
}

// MARK: - Floating tab bar

/// iOS 17 and 18: a hand-built match for Apple's Liquid Glass tab bar (iOS 26 draws the real one).
/// Bright frosted glass, a grey glass lens that springs between tabs, Apple's filled symbols and system font.
struct TabPill: View {
    @EnvironmentObject var state: AppState
    @Namespace private var lens
    /// Counts taps per tab, to trigger that tab's icon animation (see TabIcons.swift).
    @State private var taps: [AppTab: Int] = [:]

    private struct Item {
        let tab: AppTab
        let title: String
    }

    private let items: [Item] = [
        Item(tab: .home, title: "Home"),
        Item(tab: .journey, title: "Journey"),
        Item(tab: .mia, title: "Mia"),
        Item(tab: .sessions, title: "Sessions"),
        Item(tab: .community, title: "Community"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.title) { item in
                let selected = state.selectedTab == item.tab
                Button {
                    taps[item.tab, default: 0] += 1
                    state.selectedTab = item.tab
                } label: {
                    VStack(spacing: 3) {
                        TabIcon(tab: item.tab, selected: selected, taps: taps[item.tab, default: 0])
                        Text(item.title)
                            .font(.system(size: 10.5, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selected ? Theme.green : Color(hex: 0x0B1410))
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background {
                        if selected {
                            GlassLens().matchedGeometryEffect(id: "lens", in: lens)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(GlassPressStyle())
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        // Only the lens animates; the screens themselves switch instantly, as in Apple's tab bar.
        .animation(.spring(response: 0.42, dampingFraction: 0.74), value: state.selectedTab)
        .padding(4)
        .background { GlassSurface(shape: Capsule()) }
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }
}

/// Our closest match to Liquid Glass before iOS 26. Clear rather than frosted: the page stays
/// visible through it, light pools inside the thick edge, and a bright rim catches the light.
struct GlassSurface<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        shape
            .fill(.ultraThinMaterial)
            // Barely-there tint: glass, not frosting.
            .overlay(shape.fill(LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.04), .white.opacity(0.12)],
                                               startPoint: .top, endPoint: .bottom)))
            // Thick-glass edge: light gathers just inside the rim.
            .overlay(shape.strokeBorder(Color.white.opacity(0.6), lineWidth: 5).blur(radius: 4).clipShape(shape))
            // Specular rim: brightest where light hits the top left.
            .overlay(shape.strokeBorder(LinearGradient(colors: [.white, .white.opacity(0.2), .white.opacity(0.75)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            // Hairline so the edge still reads over pale backgrounds.
            .overlay(shape.stroke(Color.black.opacity(0.07), lineWidth: 0.5))
            .shadow(color: Color(hex: 0x0B1410, opacity: 0.12), radius: 22, y: 10)
            .shadow(color: Color(hex: 0x0B1410, opacity: 0.05), radius: 2, y: 1)
    }
}

/// The grey glass lens behind the selected tab.
private struct GlassLens: View {
    var body: some View {
        Capsule()
            .fill(Color(hex: 0x0B1410, opacity: 0.07))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.65), lineWidth: 4).blur(radius: 3).clipShape(Capsule()))
            .overlay(Capsule().strokeBorder(LinearGradient(colors: [.white, .white.opacity(0.25)],
                                                           startPoint: .top, endPoint: .bottom), lineWidth: 1))
            .shadow(color: Color(hex: 0x0B1410, opacity: 0.08), radius: 4, y: 2)
    }
}

/// Glass swells slightly under the finger, like Apple's interactive glass.
private struct GlassPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.07 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A photo that fills a fixed box, cropped, anchored to the top (faces stay in frame).
struct FillPhoto: View {
    let name: String
    var height: CGFloat
    var width: CGFloat? = nil
    var radius: CGFloat = 0

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .overlay(alignment: .top) {
                Image(name).resizable().scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
