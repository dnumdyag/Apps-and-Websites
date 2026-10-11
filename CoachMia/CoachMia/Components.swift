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
            .background {
                let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)
                shape.fill(Theme.greenFill)
                    // Light pooling in the upper left, and a fine rim, so the green has depth.
                    .overlay(shape.fill(RadialGradient(colors: [.white.opacity(0.12), .clear],
                                                       center: .topLeading, startRadius: 0, endRadius: 280)))
                    .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.18), .white.opacity(0.03)],
                                                               startPoint: .top, endPoint: .bottom), lineWidth: 1))
            }
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
    /// `clear` uses Apple's highly translucent variant, so more of the page shows through.
    @ViewBuilder
    func liquidGlass<S: Shape, F: View>(in shape: S, tint: Color? = nil, interactive: Bool = false, clear: Bool = false,
                                        @ViewBuilder otherwise fallback: (Self) -> F) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            let glass: Glass = clear ? .clear : .regular
            self.glassEffect((tint.map { glass.tint($0) } ?? glass).interactive(interactive), in: shape)
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
            .font(Theme.sans(13, .medium))
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
        .font(Theme.sans(12, .semibold))
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

/// Our tab bar: Apple's clear Liquid Glass on iOS 26 and later, our hand-built match on 17 and 18.
/// The selected tab sits under a droplet of glass that swells and stretches as it travels.
struct TabPill: View {
    @EnvironmentObject var state: AppState
    /// Counts taps per tab, to trigger that tab's icon animation (see TabIcons.swift).
    @State private var taps: [AppTab: Int] = [:]
    /// One per move of the droplet, so it stretches further the further it travels.
    @State private var hop = DropletHop()

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

    private func index(of tab: AppTab) -> Int {
        items.firstIndex { $0.tab == tab } ?? 0
    }

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
                            .font(Theme.sans(10, .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selected ? Theme.green : Color(hex: 0x0B1410))
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .contentShape(Capsule())
                }
                .buttonStyle(GlassPressStyle())
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        // One droplet for the whole bar, so it can travel from tab to tab instead of reappearing.
        .background {
            GeometryReader { geo in
                let width = geo.size.width / CGFloat(items.count)
                GlassDroplet(hop: hop)
                    .frame(width: width, height: geo.size.height)
                    .offset(x: width * CGFloat(index(of: state.selectedTab)))
                    // Only the droplet moves; the screens themselves switch instantly, as in Apple's tab bar.
                    .animation(.spring(response: 0.44, dampingFraction: 0.76), value: state.selectedTab)
            }
        }
        .onChange(of: state.selectedTab) { old, new in
            let from = index(of: old), to = index(of: new)
            hop = DropletHop(count: hop.count + 1, distance: abs(to - from), forward: to > from)
        }
        .padding(4)
        // iOS 26 and later: Apple's clear Liquid Glass, with a faint wash so the labels stay readable
        // over photos. iOS 17 and 18: our hand-built match.
        .background { if hasLiquidGlass { Capsule().fill(Color.white.opacity(0.12)) } }
        .liquidGlass(in: Capsule(), interactive: true, clear: true) { $0.background { GlassSurface(shape: Capsule()) } }
        .padding(.horizontal, 20)
        // Sit low like Apple's bar: about 23 pt from the bottom of the screen, dipping into the
        // home-indicator area instead of stopping above it (negative padding lets it overhang).
        .padding(.bottom, -12)
        #if DEBUG
        .task { await tourTabsForRecording() }
        #endif
    }

    #if DEBUG
    /// `-tabTour`: steps through the tabs on its own, so a screen recording can show the droplet moving.
    private func tourTabsForRecording() async {
        guard ProcessInfo.processInfo.arguments.contains("-tabTour") else { return }
        let route: [AppTab] = [.journey, .mia, .community, .home, .sessions, .journey, .home]
        try? await Task.sleep(for: .seconds(2))
        for tab in route {
            taps[tab, default: 0] += 1
            state.selectedTab = tab
            try? await Task.sleep(for: .seconds(1.4))
        }
    }
    #endif
}

/// Our closest match to Liquid Glass before iOS 26. Clear rather than frosted: the page stays
/// visible through it, light pools inside the thick edge, and a bright rim catches the light.
struct GlassSurface<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        shape
            .fill(.ultraThinMaterial)
            // Barely-there tint: glass, not frosting.
            .overlay(shape.fill(LinearGradient(colors: [.white.opacity(0.14), .white.opacity(0.02), .white.opacity(0.08)],
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

/// One move of the selection droplet: how many tabs it crosses, and which way.
private struct DropletHop: Equatable {
    var count = 0
    var distance = 1
    var forward = true
}

/// The droplet's shape at one moment of a move.
private struct DropletPose {
    var stretch: CGFloat = 1
    var swell: CGFloat = 1
    var lift: CGFloat = 0
}

/// The selected-tab lens: a droplet of clear glass. When it moves it lifts, swells, and stretches
/// toward where it is going (further for longer trips), then settles with a soft wobble.
private struct GlassDroplet: View {
    let hop: DropletHop

    var body: some View {
        let shape = Capsule()
        let ink = Color(hex: 0x0B1410)
        shape
            // A clear body: brighter at the top where it catches the light.
            .fill(LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.14), .white.opacity(0.26)],
                                 startPoint: .top, endPoint: .bottom))
            // Thick-glass edge: light pools just inside the rim.
            .overlay(shape.strokeBorder(Color.white.opacity(0.9), lineWidth: 4).blur(radius: 3).clipShape(shape))
            // A touch of shade inside the lower rim, so the droplet has depth.
            .overlay(shape.strokeBorder(LinearGradient(colors: [.clear, ink.opacity(0.12)], startPoint: .center, endPoint: .bottom),
                                        lineWidth: 3).blur(radius: 2).clipShape(shape))
            // Specular rim, brightest at the top left.
            .overlay(shape.strokeBorder(LinearGradient(colors: [.white, .white.opacity(0.2), .white.opacity(0.75)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            .shadow(color: ink.opacity(0.10), radius: 7, y: 3)
            .shadow(color: ink.opacity(0.06), radius: 1, y: 0.5)
            .keyframeAnimator(initialValue: DropletPose(), trigger: hop) { droplet, pose in
                droplet
                    // Lifted: a brighter rim and a deeper shadow.
                    .overlay(shape.strokeBorder(Color.white, lineWidth: 1.5).opacity(pose.lift))
                    .shadow(color: ink.opacity(0.12 * pose.lift), radius: 14, y: 8)
                    // Stretch from the trailing side, so the droplet reaches toward the new tab.
                    .scaleEffect(x: pose.stretch, y: pose.swell, anchor: UnitPoint(x: hop.forward ? 0.3 : 0.7, y: 0.5))
            } keyframes: { _ in
                let reach = 1.14 + 0.07 * CGFloat(min(max(hop.distance, 1), 4) - 1)
                let settle = Spring(response: 0.36, dampingRatio: 0.5)
                KeyframeTrack(\.stretch) {
                    CubicKeyframe(reach, duration: 0.14)
                    CubicKeyframe(reach * 0.96, duration: 0.12)
                    SpringKeyframe(1, duration: 0.6, spring: settle)
                }
                KeyframeTrack(\.swell) {
                    CubicKeyframe(1.12, duration: 0.14)
                    CubicKeyframe(1.08, duration: 0.12)
                    SpringKeyframe(1, duration: 0.6, spring: settle)
                }
                KeyframeTrack(\.lift) {
                    CubicKeyframe(1, duration: 0.12)
                    LinearKeyframe(1, duration: 0.16)
                    CubicKeyframe(0, duration: 0.42)
                }
            }
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
