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

/// The frosted pill tab bar from the design.
struct TabPill: View {
    @EnvironmentObject var state: AppState

    private struct Item {
        let tab: AppTab
        let title: String
        let icon: String
        let selectedIcon: String
    }

    private let items: [Item] = [
        Item(tab: .home, title: "Home", icon: "house", selectedIcon: "house.fill"),
        Item(tab: .journey, title: "Journey", icon: "point.topleft.down.curvedto.point.bottomright.up", selectedIcon: "point.topleft.down.curvedto.point.bottomright.up"),
        Item(tab: .mia, title: "Mia", icon: "bubble.left", selectedIcon: "bubble.left.fill"),
        Item(tab: .sessions, title: "Sessions", icon: "play.rectangle", selectedIcon: "play.rectangle.fill"),
        Item(tab: .community, title: "Community", icon: "person.2", selectedIcon: "person.2.fill"),
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.title) { item in
                let selected = state.selectedTab == item.tab
                Button {
                    state.selectedTab = item.tab
                } label: {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: selected ? item.selectedIcon : item.icon)
                                .font(.system(size: 19, weight: .regular))
                                .frame(height: 24)
                            if item.tab == .sessions {
                                Circle()
                                    .fill(Theme.goldDot)
                                    .overlay(Circle().stroke(Color(hex: 0xE9F3EE), lineWidth: 1.5))
                                    .frame(width: 8, height: 8)
                                    .offset(x: 5, y: -2)
                            }
                        }
                        Text(item.title)
                            .font(Theme.sans(10, selected ? .semibold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selected ? Color(hex: 0x0D1F18) : Color(hex: 0x2B3B34))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background {
                        if selected {
                            Capsule()
                                .fill(LinearGradient(colors: [.white.opacity(0.92), .white.opacity(0.62)],
                                                     startPoint: .top, endPoint: .bottom))
                                .shadow(color: Theme.ink.opacity(0.14), radius: 3, y: 2)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color(hex: 0xCDE5D8, opacity: 0.7)))
                .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                .shadow(color: Theme.ink.opacity(0.2), radius: 20, y: 12)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
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
