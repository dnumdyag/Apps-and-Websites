import SwiftUI

@main
struct CoachMiaApp: App {
    @StateObject private var state = AppState()

    init() {
        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = UIColor(Theme.bgBottom)
        tabBar.shadowColor = UIColor(Theme.border.opacity(0.4))
        let item = tabBar.stackedLayoutAppearance
        item.normal.iconColor = UIColor(Theme.textMuted)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.textMuted)]
        item.selected.iconColor = UIColor(Theme.gold)
        item.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.gold)]
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Theme.gold)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(.dark)
                .tint(Theme.gold)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        if state.profile.hasOnboarded {
            MainTabView()
                .transition(.opacity)
        } else {
            OnboardingView()
                .transition(.opacity)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        TabView(selection: $state.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)
            CoachView()
                .tabItem { Label("Mia", systemImage: "message") }
                .tag(AppTab.mia)
            JourneyView()
                .tabItem { Label("Journey", systemImage: "book") }
                .tag(AppTab.journey)
            CommunityView()
                .tabItem { Label("Community", systemImage: "person.2") }
                .tag(AppTab.community)
            SessionsView()
                .tabItem { Label("Sessions", systemImage: "video") }
                .tag(AppTab.sessions)
        }
    }
}
