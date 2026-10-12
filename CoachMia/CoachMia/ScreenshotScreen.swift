#if DEBUG
import SwiftUI

/// Opens one screen on its own for the CI screenshot job (`-screen <name>`), so every
/// screen, sheet and step can be checked without tapping through the app. Debug builds only.
/// `-screen flipbook`: every frame Apple's tab bar plays for each icon (see TabBarImage), one row per tab.
private struct FlipbookSheet: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach([AppTab.home, .journey, .mia, .sessions, .community], id: \.self) { tab in
                    let count = TabBarImage.frameCount(for: tab)
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(30), spacing: 2), count: 12), spacing: 2) {
                        ForEach(0..<count, id: \.self) { frame in
                            TabBarImage.image(for: tab, selected: true, frame: frame)
                                .background(Color.white)
                        }
                    }
                    HStack(spacing: 2) {
                        TabBarImage.image(for: tab, selected: true).background(Color.white)
                        TabBarImage.image(for: tab, selected: false).background(Color.white)
                    }
                    Divider()
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 8)
        }
        .background(Color.gray.opacity(0.3))
    }
}

struct ScreenshotScreen: View {
    let name: String

    static let names = ["quiz1", "quiz2", "quiz3", "result", "profile", "module", "membership",
                        "booking", "group", "events", "recordings", "event", "chat"]

    var body: some View {
        switch name {
        case "quiz1": OnboardingView(startStep: 1)
        case "quiz2": OnboardingView(startStep: 2)
        case "quiz3": OnboardingView(startStep: 3)
        case "result": OnboardingView(startStep: 4)
        case "profile": NavigationStack { ProfileView() }
        case "module": NavigationStack { ModuleDetailView(module: MockData.modules[2]) }
        case "membership": MembershipView()
        case "booking": BookingView()
        case "group": NavigationStack { GroupDetailView(group: MockData.groups[0]) }
        case "events": SessionsView(startSegment: .events)
        case "recordings": SessionsView(startSegment: .recordings)
        case "event": EventBookingSheet(event: MockData.memberEvents[1])
        case "icons": IconLab()
        case "flipbook": FlipbookSheet()
        case "splash": OnboardingView()
        default: MainTabView() // "chat": AppState opens the Mia tab with a sample conversation
        }
    }
}

/// The tab icons drawn large and tapped every 1.5 seconds, to check their animations on video.
private struct IconLab: View {
    @State private var taps = 0
    private let tabs: [AppTab] = [.home, .journey, .mia, .sessions, .community]

    var body: some View {
        VStack(spacing: 46) {
            ForEach(tabs, id: \.self) { tab in
                TabIcon(tab: tab, selected: true, taps: taps)
                    .foregroundStyle(Theme.green)
                    .scaleEffect(4)
                    .frame(height: 104)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                taps += 1
            }
        }
    }
}
#endif
