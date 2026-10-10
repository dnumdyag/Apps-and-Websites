import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var showMore = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var miaMessage: (String, String) {
        let day = Calendar.current.component(.weekday, from: Date())
        return MockData.miaMessages[day % MockData.miaMessages.count]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    miaCard
                    challengeCard

                    SectionLabel("Explore when you're ready")
                        .padding(.top, 8)

                    learningCard
                    liveCard
                    if let booking = state.profile.bookings.sorted(by: { $0.date < $1.date }).first(where: { $0.date >= Calendar.current.startOfDay(for: Date()) }) {
                        bookingCard(booking)
                    }
                    askMiaCard
                    deepenCard

                    SectionLabel("Reflections")
                        .padding(.top, 8)
                    reflections
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .miaBackground()
            .sheet(isPresented: $showMore) {
                MoreView()
                    .environmentObject(state)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.textMuted)
                Text("Welcome back, \(state.firstName)")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Spacer()
            Button {
                showMore = true
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Theme.border.opacity(0.6), Theme.chip.opacity(0.7)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(Circle().stroke(Theme.gold.opacity(0.25)))
                    Text(String(state.firstName.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.gold)
                }
                .frame(width: 48, height: 48)
            }
        }
        .padding(.top, 16)
    }

    private var miaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                MiaAvatar(size: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Message from Mia")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                    Text(miaMessage.0)
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Theme.text)
                }
            }
            Text(miaMessage.1)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
                .lineSpacing(4)
        }
        .miaCard(padding: 28)
    }

    private var challengeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Pill(text: "Today's challenge")
                Spacer()
                if state.streak > 0 {
                    Label("\(state.streak) day streak", systemImage: "flame")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.gold)
                }
            }
            Text(state.todaysChallenge)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
            if state.challengeDoneToday {
                Label("Done. Proud of you.", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.gold)
            } else {
                Button("I did it") {
                    withAnimation { state.completeTodaysChallenge() }
                }
                .buttonStyle(GoldButtonStyle())
            }
        }
        .miaCard()
    }

    private var learningCard: some View {
        Button {
            state.selectedTab = .journey
        } label: {
            HStack(alignment: .top, spacing: 16) {
                IconBubble(systemName: "chart.line.uptrend.xyaxis", tint: Theme.textSoft)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your learning path")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("Module \(state.nextModule.id): \(state.nextModule.title)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                    ProgressView(value: Double(state.profile.completedModules.count), total: Double(MockData.modules.count))
                        .tint(Theme.gold)
                        .padding(.top, 4)
                }
            }
            .miaCard()
        }
        .buttonStyle(.plain)
    }

    private var liveCard: some View {
        let session = MockData.liveSessions[0]
        return Button {
            state.selectedTab = .sessions
        } label: {
            HStack(alignment: .top, spacing: 16) {
                IconBubble(systemName: "play.fill", tint: Color(hex: 0xF0A0A0))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live session available")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("\(session.date), \(session.time) · \(session.title)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
            }
            .miaCard()
        }
        .buttonStyle(.plain)
    }

    private func bookingCard(_ booking: Booking) -> some View {
        HStack(alignment: .top, spacing: 16) {
            IconBubble(systemName: "calendar.badge.clock")
            VStack(alignment: .leading, spacing: 8) {
                Text("Your 1:1 with \(booking.coachName)")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Theme.text)
                Text("\(booking.date.formatted(.dateTime.weekday(.wide).month().day())) · \(booking.slot)")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.textSoft)
            }
        }
        .miaCard()
    }

    private var askMiaCard: some View {
        Button {
            state.selectedTab = .mia
        } label: {
            HStack(alignment: .top, spacing: 16) {
                IconBubble(systemName: "message")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Talk to Mia")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("Texts, dates, profiles, nerves. Share a screenshot for feedback.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
            }
            .miaCard()
        }
        .buttonStyle(.plain)
    }

    private var deepenCard: some View {
        Button {
            showMore = true
        } label: {
            HStack(alignment: .top, spacing: 16) {
                IconBubble(systemName: "crown")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deepen your journey")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("Membership, private sessions with Mia, retreats & referrals")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
            }
            .miaCard()
        }
        .buttonStyle(.plain)
    }

    private var reflections: some View {
        VStack(alignment: .leading, spacing: 22) {
            reflectionRow(icon: "sparkles",
                          title: state.streak > 0 ? "You've been showing up" : "Your streak starts today",
                          detail: "\(state.streak) day\(state.streak == 1 ? "" : "s") of presence")
            reflectionRow(icon: "chart.line.uptrend.xyaxis",
                          title: "Growing with intention",
                          detail: "\(state.profile.completedModules.count) of \(MockData.modules.count) modules completed")
            reflectionRow(icon: "person.2",
                          title: "Part of the community",
                          detail: "\(state.profile.joinedGroups.count) group\(state.profile.joinedGroups.count == 1 ? "" : "s") joined")
        }
    }

    private func reflectionRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.gold.opacity(0.8))
                .frame(width: 40, height: 40)
                .background(Theme.gold.opacity(0.08), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Theme.text)
                Text(detail)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
        }
    }
}
