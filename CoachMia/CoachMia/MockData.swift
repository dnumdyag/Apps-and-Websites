import Foundation

// All demo content lives here so Mia's team can swap in real copy quickly.

struct Module: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let minutes: Int
    let summary: String
    let keyPoints: [String]
    let exercise: String
}

struct CommunityGroup: Identifiable {
    let id: Int
    let name: String
    let description: String
    let members: Int
    let icon: String
}

struct Post: Identifiable, Codable, Hashable {
    var id = UUID()
    let groupID: Int
    let author: String
    let text: String
    var likes: Int
    let timeAgo: String
}

enum SessionKind: String {
    case live = "Live session"
    case webinar = "Webinar"
    case groupCall = "Group Q&A"
}

struct LiveSession: Identifiable {
    let id: Int
    let title: String
    let host: String
    let image: String
    let date: String
    let time: String
    let kind: SessionKind
    let attendees: Int
    let maxAttendees: Int
}

struct MemberEvent: Identifiable {
    let id: Int
    let title: String
    let theme: String
    let venue: String
    let city: String
    let date: String
    let time: String
    let spotsLeft: Int
    let price: Int // 0 = included in membership
    let icon: String
}

struct Recording: Identifiable {
    let id: Int
    let title: String
    let host: String
    let image: String
    let duration: String
    let date: String
}

struct Coach: Identifiable {
    let id: Int
    let name: String
    let specialty: String
    let image: String
    let price: Int
    let sessions: Int
    /// A wider photo for the large booking card, when the face crop in `image` is too tight.
    var cardImage: String? = nil
}

struct Retreat: Identifiable {
    let id: Int
    let title: String
    let location: String
    let dates: String
    let image: String
    let price: Int
    let spots: Int
}

struct QuizChallenge {
    let label: String
    let moduleID: Int
    let blindSpot: String
}

enum MockData {
    static let sampleVideoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!

    static let miaMessages = [
        ("You're exactly where you need to be",
         "Growth isn't about perfection. It's about showing up for yourself with kindness. Take a breath. You're doing beautifully."),
        ("Confidence is built, not found",
         "Every small brave action is a deposit. Today, make one tiny deposit and notice how it feels."),
        ("Be curious, not impressive",
         "The most attractive thing you can bring to a conversation is genuine interest in the other person."),
    ]

    static let dailyChallenges = [
        "Start a conversation with a stranger today. A simple \"how's your day going?\" counts.",
        "Give someone a genuine, specific compliment that isn't about their looks.",
        "Hold eye contact and smile at three people today.",
        "Write down three things you like about yourself that have nothing to do with dating.",
        "Ask a barista or cashier a real question and listen to the answer.",
        "Send a message to an old friend you've lost touch with.",
        "Go somewhere new on your own: a cafe, a gallery, a class.",
    ]

    static let modules: [Module] = [
        Module(id: 1, title: "Inner Confidence", subtitle: "Building unshakeable self-worth", minutes: 12,
               summary: "Real confidence isn't loud. It's the quiet knowledge that you are enough, whatever the outcome of a date.",
               keyPoints: ["Separate your worth from the result", "Keep small promises to yourself", "Replace self-criticism with curiosity"],
               exercise: "Write down 3 wins from this week, however small. Read them out loud."),
        Module(id: 2, title: "Masculine Energy", subtitle: "Understanding polarity & attraction", minutes: 15,
               summary: "Polarity is about presence, direction and calm. It's not about being dominant, it's about being grounded.",
               keyPoints: ["Lead with clarity, not control", "Presence beats performance", "Make decisions and own them"],
               exercise: "Next time you make plans, suggest a specific place and time instead of \"whatever you want\"."),
        Module(id: 3, title: "Authentic Conversation", subtitle: "Creating genuine connection", minutes: 14,
               summary: "Great conversations go beyond facts into feelings. Ask why, share a little of yourself, and listen.",
               keyPoints: ["Ask open questions", "Share stories, not resumes", "Listen for the emotion behind the words"],
               exercise: "In your next conversation, ask one \"what made you want to...\" question."),
        Module(id: 4, title: "Dating App Mastery", subtitle: "Profile, photos & messaging", minutes: 18,
               summary: "Your profile is a trailer, not the movie. Show your life, your warmth and a hook to start a conversation.",
               keyPoints: ["Lead with a clear, smiling photo", "Show, don't tell, your interests", "Write a prompt that is easy to reply to"],
               exercise: "Upload a screenshot of your profile to Mia for feedback."),
        Module(id: 5, title: "First Date Excellence", subtitle: "Planning & execution", minutes: 16,
               summary: "Choose a place where you can talk, keep it short and fun, and leave her wanting more.",
               keyPoints: ["Pick a venue with good energy", "Plan a 'second location' option", "End on a high"],
               exercise: "Plan a first date idea with Mia."),
        Module(id: 6, title: "Texting & Calling", subtitle: "Between date communication", minutes: 11,
               summary: "Texting is for logistics and playful connection, not for deep conversations. Get to the date.",
               keyPoints: ["Match her energy", "Use texts to build anticipation", "Call when it matters"],
               exercise: "Review a recent text thread with Mia."),
        Module(id: 7, title: "Physical Escalation", subtitle: "Touch, kissing & intimacy", minutes: 13,
               summary: "Respectful, gradual, and always tuned in to her comfort. Consent is attractive.",
               keyPoints: ["Read signals, then check in", "Start small and natural", "Respect a no gracefully"],
               exercise: "Reflect on how you show warmth non-verbally."),
        Module(id: 8, title: "Relationship Dynamics", subtitle: "Building something lasting", minutes: 20,
               summary: "Lasting relationships are built on trust, communication and continued courtship.",
               keyPoints: ["Understand attachment styles", "Repair after conflict", "Keep dating your partner"],
               exercise: "Take the attachment style reflection with Mia."),
    ]

    static let groups: [CommunityGroup] = [
        CommunityGroup(id: 1, name: "Heartbreak & Healing", description: "Support for moving forward stronger", members: 1247, icon: "heart"),
        CommunityGroup(id: 2, name: "Dating App Success", description: "Profile optimization & strategies", members: 2103, icon: "iphone"),
        CommunityGroup(id: 3, name: "Approaching Women", description: "Real-world practice & courage", members: 1876, icon: "figure.walk"),
        CommunityGroup(id: 4, name: "Conversation Masters", description: "Creating authentic connection", members: 1534, icon: "bubble.left.and.bubble.right"),
        CommunityGroup(id: 5, name: "Relationship Repair", description: "Fixing what is broken, growing together", members: 892, icon: "wrench.and.screwdriver"),
        CommunityGroup(id: 6, name: "First Date Preparation", description: "Planning memorable experiences", members: 1643, icon: "wineglass"),
        CommunityGroup(id: 7, name: "Wins & Success Stories", description: "Share your progress and inspire others", members: 3211, icon: "trophy"),
    ]

    /// Fixed IDs so likes on seed posts survive an app restart.
    private static func seedID(_ n: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", n))!
    }

    static let seedPosts: [Post] = [
        Post(id: seedID(1), groupID: 1, author: "Daniel R.", text: "Three months since the breakup. Today was the first day I didn't check her Instagram. Small win.", likes: 42, timeAgo: "2h"),
        Post(id: seedID(2), groupID: 1, author: "Anonymous", text: "How do you deal with the evenings? That's when it hits hardest for me.", likes: 18, timeAgo: "5h"),
        Post(id: seedID(3), groupID: 2, author: "Chris M.", text: "Swapped my sunglasses selfie for a photo of me cooking. Matches tripled in a week.", likes: 87, timeAgo: "1h"),
        Post(id: seedID(4), groupID: 2, author: "Sam T.", text: "What's a good reply to the Hinge prompt 'I geek out on...'? Mine feels flat.", likes: 12, timeAgo: "3h"),
        Post(id: seedID(5), groupID: 3, author: "Jordan K.", text: "Did the daily challenge at the bookstore. She recommended a book, we talked for 10 minutes. Didn't get her number but I'm proud I did it.", likes: 64, timeAgo: "4h"),
        Post(id: seedID(6), groupID: 4, author: "Ben A.", text: "Mia's tip about asking 'what made you want to...' questions is gold. Conversations feel so different.", likes: 39, timeAgo: "1d"),
        Post(id: seedID(7), groupID: 5, author: "Anonymous", text: "We keep having the same argument. Any advice on breaking the cycle?", likes: 9, timeAgo: "6h"),
        Post(id: seedID(8), groupID: 6, author: "Marco P.", text: "Booked the rooftop bar from the Coach Mia partner list for Friday. Nervous but excited.", likes: 25, timeAgo: "2h"),
        Post(id: seedID(9), groupID: 7, author: "Luke W.", text: "Six weeks in the app. Just had my third date with someone amazing. Thank you Mia and everyone here.", likes: 156, timeAgo: "30m"),
    ]

    static let liveSessions: [LiveSession] = [
        LiveSession(id: 1, title: "Confidence Mastery Workshop", host: "Marcus Rodriguez", image: "coach_marcus", date: "Today", time: "8:00 PM", kind: .live, attendees: 23, maxAttendees: 30),
        LiveSession(id: 2, title: "Dating App Profile Reviews", host: "Alex Turner", image: "coach_alex", date: "Tomorrow", time: "7:00 PM", kind: .webinar, attendees: 67, maxAttendees: 100),
        LiveSession(id: 5, title: "Reading Her Signals", host: "Dr. Sarah Thompson", image: "coach_sarah", date: "Wed", time: "7:30 PM", kind: .live, attendees: 41, maxAttendees: 60),
        LiveSession(id: 3, title: "Q&A: First Date Strategies", host: "David Chen", image: "coach_david", date: "Thu", time: "6:30 PM", kind: .webinar, attendees: 45, maxAttendees: 75),
        LiveSession(id: 6, title: "Texting That Leads to Dates", host: "Alex Turner", image: "coach_alex", date: "Fri", time: "6:00 PM", kind: .webinar, attendees: 88, maxAttendees: 150),
        LiveSession(id: 4, title: "Monthly Group Q&A with Mia", host: "Mia", image: "mia_avatar", date: "Sat", time: "11:00 AM", kind: .groupCall, attendees: 38, maxAttendees: 100),
        LiveSession(id: 7, title: "Healing After Heartbreak", host: "Dr. Sarah Thompson", image: "coach_sarah", date: "Sun", time: "5:00 PM", kind: .groupCall, attendees: 19, maxAttendees: 30),
        LiveSession(id: 8, title: "Style & First Impressions", host: "David Chen", image: "coach_david", date: "Mon, Oct 19", time: "8:00 PM", kind: .live, attendees: 27, maxAttendees: 50),
        LiveSession(id: 9, title: "Ask Mia Anything", host: "Mia", image: "mia_avatar", date: "Tue, Oct 20", time: "7:00 PM", kind: .groupCall, attendees: 64, maxAttendees: 100),
        LiveSession(id: 10, title: "Body Language Masterclass", host: "Marcus Rodriguez", image: "coach_marcus", date: "Wed, Oct 21", time: "7:00 PM", kind: .webinar, attendees: 52, maxAttendees: 80),
    ]

    static let eventThemes = ["All", "Sports", "Drinks", "Cigars", "Networking", "Social"]

    static let memberEvents: [MemberEvent] = [
        MemberEvent(id: 1, title: "Founders & Friends Mixer", theme: "Networking", venue: "The Collective", city: "Miami", date: "Wed, Oct 14", time: "6:30 PM", spotsLeft: 20, price: 0, icon: "person.3"),
        MemberEvent(id: 2, title: "Cigar Lounge Evening", theme: "Cigars", venue: "Havana Room", city: "Miami", date: "Thu, Oct 15", time: "7:30 PM", spotsLeft: 6, price: 45, icon: "flame"),
        MemberEvent(id: 3, title: "Members' Football Night", theme: "Sports", venue: "The Sporting Club", city: "Miami", date: "Fri, Oct 16", time: "7:00 PM", spotsLeft: 8, price: 0, icon: "sportscourt"),
        MemberEvent(id: 4, title: "Whisky & Conversation", theme: "Drinks", venue: "The Gilded Bar", city: "Miami", date: "Sat, Oct 17", time: "8:00 PM", spotsLeft: 4, price: 35, icon: "wineglass"),
        MemberEvent(id: 5, title: "Sunday Brunch Social", theme: "Social", venue: "Riverside Kitchen", city: "Miami", date: "Sun, Oct 18", time: "11:30 AM", spotsLeft: 12, price: 25, icon: "cup.and.saucer"),
        MemberEvent(id: 6, title: "Old World Reds Tasting", theme: "Drinks", venue: "Cellar 21", city: "Miami", date: "Thu, Oct 22", time: "7:30 PM", spotsLeft: 9, price: 45, icon: "wineglass"),
        MemberEvent(id: 7, title: "Cigar & Bourbon Pairing", theme: "Cigars", venue: "Oak & Ember", city: "Miami", date: "Fri, Oct 23", time: "8:00 PM", spotsLeft: 5, price: 60, icon: "flame"),
        MemberEvent(id: 8, title: "Padel & Pints", theme: "Sports", venue: "Padel Social Club", city: "Miami", date: "Sat, Oct 24", time: "2:00 PM", spotsLeft: 3, price: 20, icon: "figure.tennis"),
        MemberEvent(id: 9, title: "Breakfast with Founders", theme: "Networking", venue: "The Morning Room", city: "Miami", date: "Tue, Oct 27", time: "8:00 AM", spotsLeft: 12, price: 0, icon: "cup.and.saucer"),
        MemberEvent(id: 10, title: "A Beginner's Guide to Cigars", theme: "Cigars", venue: "Havana Room", city: "Miami", date: "Wed, Oct 28", time: "7:00 PM", spotsLeft: 12, price: 35, icon: "flame"),
        MemberEvent(id: 11, title: "Investors' Fireside Chat", theme: "Networking", venue: "The Collective", city: "Miami", date: "Thu, Oct 29", time: "6:30 PM", spotsLeft: 15, price: 20, icon: "chart.line.uptrend.xyaxis"),
        MemberEvent(id: 12, title: "Comedy Night", theme: "Social", venue: "The Punchline Room", city: "Miami", date: "Thu, Oct 29", time: "8:00 PM", spotsLeft: 17, price: 30, icon: "theatermasks"),
        MemberEvent(id: 13, title: "Rooftop Sundowners", theme: "Drinks", venue: "Skyline Terrace", city: "Miami", date: "Fri, Oct 30", time: "6:00 PM", spotsLeft: 14, price: 30, icon: "sun.horizon"),
        MemberEvent(id: 14, title: "Members' Supper Club", theme: "Social", venue: "Table Twelve", city: "Miami", date: "Fri, Oct 30", time: "8:00 PM", spotsLeft: 4, price: 65, icon: "fork.knife"),
        MemberEvent(id: 15, title: "Sunrise Run Club", theme: "Sports", venue: "The Waterfront", city: "Miami", date: "Sat, Oct 31", time: "6:30 AM", spotsLeft: 18, price: 0, icon: "figure.run"),
        MemberEvent(id: 16, title: "Cooking Class: Steak Night", theme: "Social", venue: "The Chef's Studio", city: "Miami", date: "Wed, Nov 4", time: "7:00 PM", spotsLeft: 6, price: 70, icon: "frying.pan"),
        MemberEvent(id: 17, title: "Mezcal Masterclass", theme: "Drinks", venue: "Agave House", city: "Miami", date: "Wed, Nov 4", time: "8:00 PM", spotsLeft: 6, price: 40, icon: "wineglass"),
        MemberEvent(id: 18, title: "Creatives & Coffee", theme: "Networking", venue: "Studio North", city: "Miami", date: "Sat, Nov 7", time: "10:00 AM", spotsLeft: 18, price: 0, icon: "paintpalette"),
        MemberEvent(id: 19, title: "Terrace Cigars at Sunset", theme: "Cigars", venue: "Skyline Terrace", city: "Miami", date: "Sat, Nov 7", time: "6:00 PM", spotsLeft: 8, price: 50, icon: "sun.horizon"),
        MemberEvent(id: 20, title: "Golf Morning", theme: "Sports", venue: "Palm Links", city: "Miami", date: "Sun, Nov 8", time: "8:00 AM", spotsLeft: 6, price: 85, icon: "figure.golf"),
        MemberEvent(id: 21, title: "Boxing Fundamentals", theme: "Sports", venue: "Iron Gym", city: "Miami", date: "Wed, Nov 18", time: "7:00 PM", spotsLeft: 10, price: 25, icon: "figure.boxing"),
        MemberEvent(id: 22, title: "Gallery Evening", theme: "Social", venue: "Gallery 9", city: "Miami", date: "Thu, Nov 19", time: "6:30 PM", spotsLeft: 24, price: 0, icon: "paintpalette"),
        MemberEvent(id: 23, title: "Gin & Jazz", theme: "Drinks", venue: "Velvet Lounge", city: "Miami", date: "Thu, Nov 19", time: "8:30 PM", spotsLeft: 11, price: 35, icon: "music.note"),
        MemberEvent(id: 24, title: "Cigar Rolling Demonstration", theme: "Cigars", venue: "The Leaf Room", city: "Miami", date: "Sun, Nov 22", time: "4:00 PM", spotsLeft: 9, price: 55, icon: "flame"),
        MemberEvent(id: 25, title: "Property & Finance Evening", theme: "Networking", venue: "Bayview Club", city: "Miami", date: "Wed, Nov 25", time: "7:00 PM", spotsLeft: 9, price: 25, icon: "building.2"),
        MemberEvent(id: 26, title: "Tech Founders Drinks", theme: "Networking", venue: "Signal House", city: "Miami", date: "Thu, Nov 26", time: "7:00 PM", spotsLeft: 22, price: 15, icon: "laptopcomputer"),
        MemberEvent(id: 27, title: "Live Jazz Supper", theme: "Social", venue: "Velvet Lounge", city: "Miami", date: "Sat, Nov 28", time: "8:30 PM", spotsLeft: 7, price: 45, icon: "music.note"),
        MemberEvent(id: 28, title: "Speakeasy Night", theme: "Drinks", venue: "Hidden Door", city: "Miami", date: "Sat, Nov 28", time: "9:00 PM", spotsLeft: 5, price: 40, icon: "key"),
        MemberEvent(id: 29, title: "Tennis Doubles Social", theme: "Sports", venue: "Court One Club", city: "Miami", date: "Sun, Nov 29", time: "9:00 AM", spotsLeft: 7, price: 30, icon: "figure.tennis"),
        MemberEvent(id: 30, title: "Cigars & Chess", theme: "Cigars", venue: "Oak & Ember", city: "Miami", date: "Tue, Dec 1", time: "7:30 PM", spotsLeft: 6, price: 40, icon: "flame"),
        MemberEvent(id: 31, title: "Golden Hour Networking", theme: "Networking", venue: "Skyline Terrace", city: "Miami", date: "Fri, Dec 4", time: "6:00 PM", spotsLeft: 13, price: 20, icon: "sun.horizon"),
        MemberEvent(id: 32, title: "Members' Humidor Night", theme: "Cigars", venue: "The Gentlemen's Room", city: "Miami", date: "Fri, Dec 4", time: "8:30 PM", spotsLeft: 10, price: 0, icon: "flame"),
        MemberEvent(id: 33, title: "Sailing Afternoon", theme: "Sports", venue: "Harbour Marina", city: "Miami", date: "Sat, Dec 5", time: "1:00 PM", spotsLeft: 4, price: 95, icon: "sailboat"),
        MemberEvent(id: 34, title: "Craft Beer Tasting", theme: "Drinks", venue: "Harbour Brewing", city: "Miami", date: "Sun, Dec 6", time: "3:00 PM", spotsLeft: 16, price: 25, icon: "mug"),
        MemberEvent(id: 35, title: "Movie Night Under the Stars", theme: "Social", venue: "Rooftop Cinema", city: "Miami", date: "Sun, Dec 6", time: "7:30 PM", spotsLeft: 19, price: 20, icon: "film"),
    ]

    static let recordings: [Recording] = [
        Recording(id: 1, title: "Overcoming Approach Anxiety", host: "Marcus Rodriguez", image: "coach_marcus", duration: "1h 32m", date: "Oct 3"),
        Recording(id: 2, title: "Authentic Conversation Techniques", host: "David Chen", image: "coach_david", duration: "1h 18m", date: "Sep 28"),
        Recording(id: 3, title: "Building Emotional Intelligence", host: "Dr. Sarah Thompson", image: "coach_sarah", duration: "1h 45m", date: "Sep 21"),
    ]

    static let coaches: [Coach] = [
        Coach(id: 0, name: "Mia", specialty: "Founder · Dating & Relationships", image: "mia_avatar", price: 200, sessions: 2310, cardImage: "mia_hero"),
        Coach(id: 1, name: "Marcus Rodriguez", specialty: "Confidence & Mindset", image: "coach_marcus", price: 150, sessions: 1247),
        Coach(id: 2, name: "Alex Turner", specialty: "Dating Apps & Online", image: "coach_alex", price: 130, sessions: 1534),
        Coach(id: 3, name: "David Chen", specialty: "Social Dynamics", image: "coach_david", price: 120, sessions: 892),
    ]

    static let timeSlots = ["9:00 AM", "11:00 AM", "1:00 PM", "3:00 PM", "6:00 PM", "8:00 PM"]

    static let retreats: [Retreat] = [
        Retreat(id: 1, title: "Confidence & Connection Intensive", location: "Sedona, Arizona", dates: "April 10 to 13, 2027", image: "retreat_sedona", price: 2499, spots: 3),
        Retreat(id: 2, title: "Social Mastery Immersion", location: "Miami, Florida", dates: "May 15 to 18, 2027", image: "retreat_miami", price: 2799, spots: 5),
    ]

    static let premiumFeatures = [
        "Unlimited AI Coach conversations",
        "All learning modules unlocked",
        "Priority access to live sessions",
        "Private community groups",
        "Weekly 1:1 check-ins",
        "Exclusive retreat invitations",
    ]

    static let goals = [
        "Build confidence",
        "Attract the right partner",
        "Better conversations",
        "Dating app success",
        "Heal from a breakup",
        "Improve my relationship",
    ]

    static let challenges: [QuizChallenge] = [
        QuizChallenge(label: "Approaching & starting conversations", moduleID: 3, blindSpot: "Waiting for the perfect moment"),
        QuizChallenge(label: "Getting matches on apps", moduleID: 4, blindSpot: "Hiding the real you online"),
        QuizChallenge(label: "Turning chats into dates", moduleID: 6, blindSpot: "Staying in the chat too long"),
        QuizChallenge(label: "Feeling confident in myself", moduleID: 1, blindSpot: "Looking for approval before self-worth"),
        QuizChallenge(label: "Making relationships last", moduleID: 8, blindSpot: "Avoiding the hard conversations"),
    ]
}
