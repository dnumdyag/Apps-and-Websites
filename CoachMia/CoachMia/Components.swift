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
/// The selected tab rests on a soft platter. Touch the bar and the platter lifts into a lens of glass,
/// taller than the bar, that magnifies the tabs under it and follows the finger; let go and it drops
/// onto that tab. Tab changes made elsewhere in the app glide the lens across the same way.
struct TabPill: View {
    @EnvironmentObject var state: AppState
    /// Counts taps per tab, to trigger that tab's icon animation (see TabIcons.swift).
    @State private var taps: [AppTab: Int] = [:]
    /// Width of the row of tabs.
    @State private var width: CGFloat = 0
    /// The tab the platter rests on. It moves only when the lens drops, so it never slides into view.
    @State private var restIndex = 0
    /// The lens is up: a bubble of glass over the bar.
    @State private var lifted = false
    /// Centre of the lifted lens; nil when it sits on `restIndex`.
    @State private var lensX: CGFloat?
    /// Grows with the finger's speed, so a quick swipe pulls the lens long.
    @State private var stretch: CGFloat = 1
    @State private var touching = false
    /// Set when the bar itself changes the tab, so the lens doesn't glide across a second time.
    @State private var changingTab = false
    @State private var drop: Task<Void, Never>?

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

    private let rowHeight: CGFloat = 54
    private let inset: CGFloat = 4
    private let magnification: CGFloat = 1.22
    private let ink = Color(hex: 0x0B1410)

    private var slot: CGFloat { width / CGFloat(items.count) }
    private func index(of tab: AppTab) -> Int { items.firstIndex { $0.tab == tab } ?? 0 }
    private func centre(of i: Int) -> CGFloat { slot * (CGFloat(i) + 0.5) }
    private func nearest(_ x: CGFloat) -> Int { min(max(Int(x / max(slot, 1)), 0), items.count - 1) }
    private var lensCentre: CGFloat { lensX ?? centre(of: restIndex) }
    /// Lifted, the lens overhangs the bar above and below; resting, it is the size of the platter.
    private var lensSize: CGSize {
        lifted ? CGSize(width: slot * 1.16 * stretch, height: rowHeight + 2 * inset + 14)
               : CGSize(width: slot, height: rowHeight)
    }

    var body: some View {
        ZStack {
            row(inLens: false)
                .mask { lensHole }
                .background(alignment: .leading) { platter }
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { width = geo.size.width }
                            .onChange(of: geo.size.width) { _, newWidth in width = newWidth }
                    }
                }
                .padding(inset)
                // iOS 26 and later: Apple's clear Liquid Glass, with a faint wash so the labels stay readable
                // over photos. iOS 17 and 18: our hand-built match.
                .background { if hasLiquidGlass { Capsule().fill(Color.white.opacity(0.12)) } }
                .liquidGlass(in: Capsule(), clear: true) { $0.background { GlassSurface(shape: Capsule()) } }
            lensGlass
                .padding(inset)
            lensView
                .padding(inset)
        }
        .contentShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { touch(at: $0.location.x - inset, speed: $0.velocity.width) }
                .onEnded { _ in release() }
        )
        .onAppear { restIndex = index(of: state.selectedTab) }
        .onChange(of: state.selectedTab) { _, newTab in
            if changingTab { changingTab = false } else { glide(to: index(of: newTab)) }
        }
        .padding(.horizontal, 20)
        // Sit low like Apple's bar: about 23 pt from the bottom of the screen, dipping into the
        // home-indicator area instead of stopping above it (negative padding lets it overhang).
        .padding(.bottom, -12)
        #if DEBUG
        .task { await tourForRecording() }
        #endif
    }

    /// The five tabs. The lens draws them again, magnified, with the tab under it selected.
    private func row(inLens: Bool) -> some View {
        let lensIndex = nearest(lensCentre)
        return HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                let selected = inLens ? i == lensIndex : item.tab == state.selectedTab
                VStack(spacing: 3) {
                    TabIcon(tab: item.tab, selected: selected, taps: taps[item.tab, default: 0])
                    Text(item.title)
                        .font(Theme.sans(10, .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(selected ? Theme.green : ink)
                .frame(maxWidth: .infinity, minHeight: rowHeight)
                .contentShape(Rectangle())
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
                .accessibilityAction {
                    select(i)
                    settle(on: i, after: 0)
                }
            }
        }
        .accessibilityHidden(inLens)
    }

    /// Where the selected tab rests: a soft platter, as in Apple's bar.
    private var platter: some View {
        Capsule()
            .fill(ink.opacity(0.08))
            .frame(width: slot, height: rowHeight)
            .offset(x: slot * CGFloat(restIndex))
            // It jumps while hidden under the lens, then fades in where the lens dropped.
            .animation(nil, value: restIndex)
            .opacity(lifted ? 0 : 1)
    }

    /// Cuts the lens out of the row underneath; the lens draws that part instead. Resting, the lens is
    /// the platter and shows the tab unmagnified, so the two layers meet without a seam.
    private var lensHole: some View {
        Rectangle()
            .overlay {
                Capsule()
                    .frame(width: lensSize.width, height: lensSize.height)
                    .position(x: lensCentre, y: rowHeight / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
    }

    /// The lens's glass. It fades in as the lens lifts and out as it drops back into the platter.
    /// Painted rather than Apple's glass: Apple's glass drawn over the glass bar came out as a flat
    /// white blob on iOS 26 (cloud recording, 12 October 2026).
    private var lensGlass: some View {
        GlassDroplet()
            .frame(width: lensSize.width, height: lensSize.height)
            .opacity(lifted ? 1 : 0)
            .position(x: lensCentre, y: rowHeight / 2)
            .frame(width: width, height: rowHeight)
            .allowsHitTesting(false)
    }

    /// What the lens shows: the tabs under it, magnified while it is lifted.
    private var lensView: some View {
        let size = lensSize
        let x = lensCentre
        return row(inLens: true)
            .frame(width: width, height: rowHeight)
            .scaleEffect(lifted ? magnification : 1, anchor: UnitPoint(x: width > 0 ? x / width : 0.5, y: 0.5))
            // Line the row up so the point under the lens sits at the lens's centre.
            .offset(x: size.width / 2 - x, y: (size.height - rowHeight) / 2)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
            .clipShape(Capsule())
            .position(x: x, y: rowHeight / 2)
            .frame(width: width, height: rowHeight)
            .allowsHitTesting(false)
    }

    /// Finger down or moving on the bar: the lens lifts and stays under the finger.
    private func touch(at x: CGFloat, speed: CGFloat) {
        guard width > 0 else { return }
        drop?.cancel()
        let x = min(max(x, slot / 2), width - slot / 2)
        if touching {
            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.82)) {
                lensX = x
                stretch = 1 + min(abs(speed) / 2800, 0.28)
            }
        } else {
            touching = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                lifted = true
                lensX = x
            }
        }
    }

    /// Finger up: the tab under the lens opens and the lens drops onto it.
    private func release() {
        touching = false
        guard width > 0 else { return }
        let i = nearest(lensCentre)
        select(i)
        settle(on: i, after: 0)
    }

    private func select(_ i: Int) {
        let tab = items[i].tab
        taps[tab, default: 0] += 1
        if state.selectedTab != tab {
            changingTab = true
            state.selectedTab = tab
        }
    }

    /// A tab change from elsewhere in the app: the lens lifts, glides across and drops.
    private func glide(to i: Int) {
        guard width > 0 else {
            restIndex = i
            return
        }
        let distance = abs(i - nearest(lensCentre))
        withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
            lifted = true
            lensX = centre(of: i)
            stretch = 1 + 0.05 * CGFloat(min(distance, 4))
        }
        settle(on: i, after: 0.36)
    }

    /// The lens shrinks back into the platter on tab `i`.
    private func settle(on i: Int, after delay: Double) {
        drop?.cancel()
        drop = Task { @MainActor in
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) {
                restIndex = i
                lifted = false
                lensX = nil
                stretch = 1
            }
        }
    }

    #if DEBUG
    /// `-tabTour`: tab changes and a slow drag along the bar, on their own, so a screen recording
    /// can show the lens.
    private func tourForRecording() async {
        guard ProcessInfo.processInfo.arguments.contains("-tabTour") else { return }
        try? await Task.sleep(for: .seconds(2))
        for tab in [AppTab.journey, .community, .home] {
            taps[tab, default: 0] += 1
            state.selectedTab = tab
            try? await Task.sleep(for: .seconds(1.4))
        }
        // A finger pressing on Home, sliding along to Community, back to Mia, and letting go.
        let path = Array(stride(from: 0.1, through: 0.9, by: 0.02)) + Array(stride(from: 0.9, through: 0.5, by: -0.02))
        touch(at: width * 0.1, speed: 0)
        try? await Task.sleep(for: .seconds(0.5))
        for p in path {
            touch(at: width * p, speed: 500)
            try? await Task.sleep(for: .milliseconds(40))
        }
        try? await Task.sleep(for: .seconds(0.5))
        release()
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

/// Our bar's lens, a droplet of clear glass. Light pools in its thick rim
/// and a soft shadow lifts it off the bar.
private struct GlassDroplet: View {
    var body: some View {
        let shape = Capsule()
        let ink = Color(hex: 0x0B1410)
        shape
            .fill(LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.14), .white.opacity(0.26)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(shape.strokeBorder(Color.white.opacity(0.9), lineWidth: 4).blur(radius: 3).clipShape(shape))
            .overlay(shape.strokeBorder(LinearGradient(colors: [.clear, ink.opacity(0.12)], startPoint: .center, endPoint: .bottom),
                                        lineWidth: 3).blur(radius: 2).clipShape(shape))
            .overlay(shape.strokeBorder(LinearGradient(colors: [.white, .white.opacity(0.2), .white.opacity(0.75)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            .shadow(color: ink.opacity(0.14), radius: 12, y: 6)
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
