import SwiftUI

@main
struct CoachMiaApp: App {
    @StateObject private var state = AppState()

    init() {
        Theme.registerFonts()

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.ink),
            .font: UIFont(name: "Montserrat-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold),
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Theme.green)

        // Apple's tab bar (iOS 26 and later): tab titles in our sans, as in our own bar.
        if let tabFont = UIFont(name: "Montserrat-SemiBold", size: 10) {
            UITabBarItem.appearance().setTitleTextAttributes([.font: tabFont], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.font: tabFont], for: .selected)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(.light)
                .tint(Theme.green)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Group {
            #if DEBUG
            if let screen = state.screenshotScreen {
                ScreenshotScreen(name: screen)
            } else {
                appContent
            }
            #else
            appContent
            #endif
        }
        .animation(.easeInOut(duration: 0.3), value: state.profile.hasOnboarded)
    }

    @ViewBuilder private var appContent: some View {
        if state.profile.hasOnboarded {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    /// iOS 26 and later: true (the default) uses Apple's own Liquid Glass tab bar, whose selection
    /// lifts into a magnifying lens under the finger; our icons play their animations in it as
    /// flipbooks. False uses our own bar. Launching with -customTabBar or -systemTabBar switches
    /// it and the choice is kept, so a phone can be switched without a new build.
    static var systemTabBar: Bool {
        let defaults = UserDefaults.standard
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-customTabBar") { defaults.set(false, forKey: "systemTabBar") }
        if args.contains("-systemTabBar") { defaults.set(true, forKey: "systemTabBar") }
        return defaults.object(forKey: "systemTabBar") as? Bool ?? true
    }

    /// True when the screen shows Apple's tab bar rather than ours.
    static var usesSystemTabBar: Bool { hasLiquidGlass && systemTabBar }

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *), Self.systemTabBar {
            GlassTabView()
        } else {
            PillTabView()
        }
        #else
        PillTabView()
        #endif
    }
}

#if compiler(>=6.2)
/// iOS 26 and later: Apple's Liquid Glass tab bar. It shows images rather than live views, so each
/// icon's tap animation plays as a flipbook: frames drawn ahead of time, swapped 30 times a second
/// (tested in the cloud recording, 12 October 2026: swapped images animate, a live view stays still).
@available(iOS 26.0, *)
private struct GlassTabView: View {
    @EnvironmentObject var state: AppState
    /// The animation frame each tab's icon is showing; no entry while it is at rest.
    @State private var frames: [AppTab: Int] = [:]
    @State private var player: Task<Void, Never>?

    var body: some View {
        TabView(selection: selection) {
            Tab(value: AppTab.home) { HomeView() } label: { label("Home", .home) }
            Tab(value: AppTab.journey) { JourneyView() } label: { label("Journey", .journey) }
            Tab(value: AppTab.mia) { CoachView() } label: { label("Mia", .mia) }
            Tab(value: AppTab.sessions) { SessionsView() } label: { label("Sessions", .sessions) }
            Tab(value: AppTab.community) { CommunityView() } label: { label("Community", .community) }
        }
        .onChange(of: state.selectedTab) { _, tab in play(tab) }
        .task { await TabBarImage.prepare() }
        #if DEBUG
        .task { await tourForRecording() }
        #endif
    }

    /// Tapping the tab that is already open plays its animation again, as in our own bar.
    private var selection: Binding<AppTab> {
        Binding(get: { state.selectedTab }, set: { tab in
            if tab == state.selectedTab { play(tab) }
            state.selectedTab = tab
        })
    }

    private func label(_ title: String, _ tab: AppTab) -> some View {
        Label { Text(title) } icon: {
            TabBarImage.image(for: tab, selected: state.selectedTab == tab, frame: frames[tab])
        }
    }

    /// Plays `tab`'s icon animation; any other icon still moving goes straight back to rest.
    private func play(_ tab: AppTab) {
        player?.cancel()
        frames = [:]
        player = Task { @MainActor in
            let clock = ContinuousClock()
            let start = clock.now
            for frame in 0..<TabBarImage.frameCount(for: tab) {
                guard !Task.isCancelled else { return }
                frames[tab] = frame
                try? await clock.sleep(until: start + TabBarImage.frameLength * (frame + 1))
            }
            frames[tab] = nil
        }
    }

    #if DEBUG
    /// -tabTour: tab changes on their own, so a screen recording can show the icons.
    private func tourForRecording() async {
        guard ProcessInfo.processInfo.arguments.contains("-tabTour") else { return }
        try? await Task.sleep(for: .seconds(2))
        for tab in [AppTab.journey, .mia, .sessions, .community, .home] {
            state.selectedTab = tab
            try? await Task.sleep(for: .seconds(2))
        }
    }
    #endif
}
#endif

/// Our tab icons as images for Apple's tab bar, in our own colours: green with gold details when
/// selected, ink when not. Each is drawn on the same 30 x 30 pt canvas, so the icons keep their
/// shared baseline. Frames of the tap animations are kept once drawn.
@MainActor
enum TabBarImage {
    static let framesPerSecond = 30
    static var frameLength: Duration { .seconds(1) / framesPerSecond }

    private struct Key: Hashable {
        let tab: AppTab
        let selected: Bool
        let frame: Int?
    }

    private static var cache: [Key: Image] = [:]

    /// Frames in a tab's animation, the last one at rest.
    static func frameCount(for tab: AppTab) -> Int {
        Int((TabIcon.duration(of: tab) * Double(framesPerSecond)).rounded(.up)) + 1
    }

    /// The icon at rest, or at `frame` of its tap animation.
    static func image(for tab: AppTab, selected: Bool, frame: Int? = nil) -> Image {
        let key = Key(tab: tab, selected: selected, frame: frame)
        if let image = cache[key] { return image }
        let time = frame.map { Double($0) / Double(framesPerSecond) }
        let renderer = ImageRenderer(content: TabIcon(tab: tab, selected: selected, taps: 0, time: time)
            .foregroundStyle(selected ? Theme.green : Color(hex: 0x0B1410))
            .frame(width: 30, height: 30))
        renderer.scale = 3
        guard let drawn = renderer.uiImage else { return Image(systemName: "circle") }
        let image = Image(uiImage: drawn.withRenderingMode(.alwaysOriginal))
        cache[key] = image
        return image
    }

    /// Draws every selected icon's frames ahead of time, one at a time between screen updates,
    /// so the first tap on each tab already plays smoothly.
    static func prepare() async {
        for tab in [AppTab.home, .journey, .mia, .sessions, .community] {
            for frame in 0..<frameCount(for: tab) {
                _ = image(for: tab, selected: true, frame: frame)
                await Task.yield()
            }
        }
    }
}

/// Our tab bar with the animated icons: real Liquid Glass on iOS 26 and later, our hand-built glass on 17 and 18.
private struct PillTabView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            switch state.selectedTab {
            case .home: HomeView()
            case .journey: JourneyView()
            case .mia: CoachView()
            case .sessions: SessionsView()
            case .community: CommunityView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !state.hideTabBar {
                TabPill()
                    // The page shows through the glass; only the strip below the bar is covered,
                    // so nothing runs into the home indicator.
                    .background {
                        LinearGradient(stops: [.init(color: Theme.background.opacity(0), location: 0),
                                               .init(color: Theme.background.opacity(0), location: 0.56),
                                               .init(color: Theme.background, location: 0.63)],
                                       startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea(edges: .bottom)
                            .allowsHitTesting(false)
                    }
            }
        }
    }
}
