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
    /// lifts into a magnifying lens under the finger, showing our icons as still images. False uses
    /// our own bar, where the icons animate. Launching with -customTabBar or -systemTabBar switches
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
/// iOS 26 and later: Apple's Liquid Glass tab bar, with our icons drawn into still images.
@available(iOS 26.0, *)
private struct GlassTabView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            Tab(value: AppTab.home) { HomeView() } label: { label("Home", .home) }
            Tab(value: AppTab.journey) { JourneyView() } label: { label("Journey", .journey) }
            Tab(value: AppTab.mia) { CoachView() } label: { label("Mia", .mia) }
            Tab(value: AppTab.sessions) { SessionsView() } label: { label("Sessions", .sessions) }
            Tab(value: AppTab.community) { CommunityView() } label: { label("Community", .community) }
        }
        #if DEBUG
        .onChange(of: state.selectedTab) { _, tab in
            taps[tab, default: 0] += 1
            if tab == .sessions { Task { await spinCigar() } }
        }
        .task { await tourForRecording() }
        #endif
    }

    @ViewBuilder private func label(_ title: String, _ tab: AppTab) -> some View {
        #if DEBUG
        if iconTest {
            testLabel(title, tab)
        } else {
            Label { Text(title) } icon: { TabBarImage.image(for: tab) }
        }
        #else
        Label { Text(title) } icon: { TabBarImage.image(for: tab) }
        #endif
    }

    #if DEBUG
    // -tabIconTest: three ways of animating an icon inside Apple's bar, for a screen recording.
    // Home: our live animated view. Journey: an Apple symbol with Apple's bounce effect.
    // Sessions: still images swapped 30 times a second.
    private var iconTest: Bool { ProcessInfo.processInfo.arguments.contains("-tabIconTest") }
    @State private var taps: [AppTab: Int] = [:]
    @State private var spin: Double = 0

    @ViewBuilder private func testLabel(_ title: String, _ tab: AppTab) -> some View {
        switch tab {
        case .home:
            Label { Text(title) } icon: {
                TabIcon(tab: .home, selected: state.selectedTab == .home, taps: taps[.home, default: 0])
            }
        case .journey:
            Label { Text(title) } icon: {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .symbolEffect(.bounce, value: taps[.journey, default: 0])
            }
        case .sessions:
            Label { Text(title) } icon: { TabBarImage.spun(for: .sessions, degrees: -30 * sin(spin * .pi)) }
        default:
            Label { Text(title) } icon: { TabBarImage.image(for: tab) }
        }
    }

    private func spinCigar() async {
        for frame in 0...30 {
            spin = Double(frame) / 30
            try? await Task.sleep(for: .milliseconds(33))
        }
        spin = 0
    }

    /// -tabTour: tab changes on their own, so a screen recording can show the icons.
    private func tourForRecording() async {
        guard ProcessInfo.processInfo.arguments.contains("-tabTour") else { return }
        try? await Task.sleep(for: .seconds(2))
        for tab in [AppTab.sessions, .home, .journey, .sessions, .home, .journey] {
            state.selectedTab = tab
            try? await Task.sleep(for: .seconds(1.6))
        }
    }
    #endif
}
#endif

/// Our tab icons as still images for Apple's tab bar. Each is drawn on the same 30 x 30 pt canvas,
/// so the icons keep their shared baseline. Apple's bar tints them, except the Mia orb, which keeps
/// its green and gold.
@MainActor
enum TabBarImage {
    private static var cache: [AppTab: Image] = [:]

    static func image(for tab: AppTab) -> Image {
        if let image = cache[tab] { return image }
        let renderer = ImageRenderer(content: TabIcon(tab: tab, selected: tab == .mia, taps: 0)
            .foregroundStyle(Color.black)
            .frame(width: 30, height: 30))
        renderer.scale = 3
        guard let drawn = renderer.uiImage else { return Image(systemName: "circle") }
        let image = Image(uiImage: drawn.withRenderingMode(tab == .mia ? .alwaysOriginal : .alwaysTemplate))
        cache[tab] = image
        return image
    }

    #if DEBUG
    /// A tab icon drawn turned by `degrees` (the -tabIconTest recording).
    static func spun(for tab: AppTab, degrees: Double) -> Image {
        let renderer = ImageRenderer(content: TabIcon(tab: tab, selected: false, taps: 0)
            .rotationEffect(.degrees(degrees))
            .foregroundStyle(Color.black)
            .frame(width: 30, height: 30))
        renderer.scale = 3
        guard let drawn = renderer.uiImage else { return Image(systemName: "circle") }
        return Image(uiImage: drawn.withRenderingMode(.alwaysTemplate))
    }
    #endif
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
