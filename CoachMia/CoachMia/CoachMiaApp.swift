import SwiftUI

@main
struct CoachMiaApp: App {
    @StateObject private var state = AppState()

    init() {
        Theme.registerFonts()

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [.foregroundColor: UIColor(Theme.ink)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Theme.green)
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
    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
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
/// iOS 26 and later: Apple's Liquid Glass tab bar, which shrinks while scrolling down.
@available(iOS 26.0, *)
private struct GlassTabView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) { HomeView() }
            Tab("Journey", systemImage: "point.topleft.down.curvedto.point.bottomright.up", value: AppTab.journey) { JourneyView() }
            Tab("Mia", systemImage: "bubble.left", value: AppTab.mia) { CoachView() }
            Tab("Sessions", systemImage: "play.rectangle", value: AppTab.sessions) { SessionsView() }
            Tab("Community", systemImage: "person.2", value: AppTab.community) { CommunityView() }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
#endif

/// iOS 17 and 18: the frosted pill tab bar from the design.
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
