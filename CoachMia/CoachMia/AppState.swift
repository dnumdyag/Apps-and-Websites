import SwiftUI

enum AppTab: Hashable {
    case home, journey, mia, sessions, community
}

struct Booking: Identifiable, Codable, Hashable {
    var id = UUID()
    let coachName: String
    let date: Date
    let slot: String
    let price: Int
}

/// Everything we remember about the user. Saved to UserDefaults as JSON.
struct UserProfile: Codable {
    var name = ""
    var age = ""
    var relationshipStatus = "Single"
    var goals: [String] = []
    var focusModuleID = 1
    var blindSpot = ""
    var avatarData: Data?
    var hasOnboarded = false
    var isPremium = false
    var completedModules: Set<Int> = []
    var joinedGroups: Set<Int> = [7]
    var reservedSessions: Set<Int> = []
    var bookedEvents: Set<Int> = []
    var bookings: [Booking] = []
    var userPosts: [Post] = []
    var likedPosts: Set<UUID> = []
    var challengeDays: Set<String> = []
    var aiMessagesUsed = 0
    var aiMonth = ""
    var referralCode = "MIA-" + String(UUID().uuidString.prefix(5))
    var joinedAt = Date()
}

@MainActor
final class AppState: ObservableObject {
    static let freeMessagesPerMonth = 30
    private static let storageKey = "coachmia.profile.v1"
    private static let apiKeyKey = "coachmia.anthropicKey"

    @Published var profile: UserProfile {
        didSet { save() }
    }
    @Published var selectedTab: AppTab = .home
    /// Text a screen wants pre-filled in the Mia chat (e.g. "Ask Mia about this module").
    @Published var pendingMiaPrompt: String?
    /// The Mia conversation. Kept here so it survives switching tabs.
    @Published var chatMessages: [ChatMessage] = []
    /// Hidden while typing to Mia so the keyboard has room.
    @Published var hideTabBar = false
    /// CI screenshot job: `-screen profile` (etc.) opens that one screen. See ScreenshotScreen.
    @Published var screenshotScreen: String?

    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: Self.apiKeyKey) }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        } else {
            profile = UserProfile()
        }
        apiKey = UserDefaults.standard.string(forKey: Self.apiKeyKey) ?? Config.anthropicAPIKey
        // Launched with -resetDemo (from the Mac, to set up a phone for a demo): start again
        // from the splash and Mia's interview.
        if ProcessInfo.processInfo.arguments.contains("-resetDemo") { resetDemo() }
        applyScreenshotArguments()
    }

    /// Used by the CI screenshot job: `-demoProfile` fills in a sample member,
    /// `-tab journey` (etc.) opens that tab.
    private func applyScreenshotArguments() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-demoProfile") {
            var p = UserProfile()
            p.name = "James"
            p.age = "32"
            p.goals = ["Attract the right partner"]
            p.focusModuleID = 3
            p.blindSpot = "Waiting for the perfect moment"
            p.completedModules = [1, 2]
            p.joinedGroups = [1, 2]
            p.isPremium = true
            p.hasOnboarded = true
            let today = Date()
            p.challengeDays = Set((1...6).compactMap { offset in
                Calendar.current.date(byAdding: .day, value: -offset, to: today).map { dayKey($0) }
            })
            profile = p
        }
        if let i = args.firstIndex(of: "-screen"), i + 1 < args.count {
            screenshotScreen = args[i + 1]
            if ["miaSession", "miaPlan", "miaLive"].contains(args[i + 1]) {
                selectedTab = .mia
            }
            if args[i + 1] == "chat" {
                selectedTab = .mia
                let question = ChatMessage(role: .user, text: "We matched on Hinge and the chat is fun, but I don't know how to ask her out.")
                chatMessages = [
                    ChatMessage(role: .assistant, text: "Hi James. I'm here whenever you need to talk. What's on your heart today?"),
                    question,
                    ChatMessage(role: .assistant, text: MiaAI.offlineReply(for: question)),
                ]
            }
        }
        if let i = args.firstIndex(of: "-tab"), i + 1 < args.count {
            switch args[i + 1] {
            case "journey": selectedTab = .journey
            case "mia": selectedTab = .mia
            case "sessions": selectedTab = .sessions
            case "community": selectedTab = .community
            default: selectedTab = .home
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    func resetDemo() {
        profile = UserProfile()
        chatMessages = []
        selectedTab = .home
    }

    var firstName: String {
        let trimmed = profile.name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "there" : String(trimmed.split(separator: " ").first ?? "")
    }

    // MARK: Learning path

    func isUnlocked(_ module: Module) -> Bool {
        if profile.isPremium { return true }
        if module.id <= 5 { return true }
        return profile.completedModules.contains(module.id - 1)
    }

    var nextModule: Module {
        let focus = MockData.modules.first { $0.id == profile.focusModuleID && !profile.completedModules.contains($0.id) }
        return focus
            ?? MockData.modules.first { !profile.completedModules.contains($0.id) && isUnlocked($0) }
            ?? MockData.modules[0]
    }

    func toggleComplete(_ module: Module) {
        if profile.completedModules.contains(module.id) {
            profile.completedModules.remove(module.id)
        } else {
            profile.completedModules.insert(module.id)
        }
    }

    // MARK: Daily challenge & streak

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func dayKey(_ date: Date) -> String { Self.dayFormatter.string(from: date) }

    var todaysChallenge: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return MockData.dailyChallenges[day % MockData.dailyChallenges.count]
    }

    var challengeDoneToday: Bool { profile.challengeDays.contains(dayKey(Date())) }

    func completeTodaysChallenge() {
        profile.challengeDays.insert(dayKey(Date()))
    }

    var streak: Int {
        var count = 0
        var day = Date()
        if !profile.challengeDays.contains(dayKey(day)) {
            day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while profile.challengeDays.contains(dayKey(day)) {
            count += 1
            day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    // MARK: AI allowance

    private var currentMonth: String {
        String(dayKey(Date()).prefix(7))
    }

    var aiMessagesLeft: Int {
        if profile.aiMonth != currentMonth { return Self.freeMessagesPerMonth }
        return max(0, Self.freeMessagesPerMonth - profile.aiMessagesUsed)
    }

    func recordAIMessage() {
        if profile.aiMonth != currentMonth {
            profile.aiMonth = currentMonth
            profile.aiMessagesUsed = 0
        }
        profile.aiMessagesUsed += 1
    }

    // MARK: Community

    func posts(for group: CommunityGroup) -> [Post] {
        let mine = Array(profile.userPosts.filter { $0.groupID == group.id }.reversed())
        return mine + MockData.seedPosts.filter { $0.groupID == group.id }
    }

    func toggleLike(_ post: Post) {
        if profile.likedPosts.contains(post.id) {
            profile.likedPosts.remove(post.id)
        } else {
            profile.likedPosts.insert(post.id)
        }
    }

    func addPost(_ text: String, to group: CommunityGroup, anonymous: Bool) {
        let author = anonymous ? "Anonymous" : (profile.name.isEmpty ? "Member" : profile.name)
        profile.userPosts.append(Post(groupID: group.id, author: author, text: text, likes: 0, timeAgo: "now"))
    }
}
