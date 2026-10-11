import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState

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

    private var completed: Int { state.profile.completedModules.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("Explore when you're ready")
                        learningCard
                        liveCard
                        if let booking = upcomingBooking {
                            bookingCard(booking)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel("Reflections")
                        HStack(spacing: 12) {
                            statTile(value: "\(state.streak)", unit: state.streak == 1 ? "day" : "days",
                                     caption: state.streak > 0 ? "You've been showing up" : "Your streak starts today")
                            statTile(value: "\(completed)", unit: completed == 1 ? "module" : "modules",
                                     caption: "Growing with intention")
                        }
                    }

                    challengeCard
                    miaCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .tabBarClearance()
            .screenBackground()
            .screenshotScrollEnd()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var upcomingBooking: Booking? {
        let today = Calendar.current.startOfDay(for: Date())
        return state.profile.bookings.filter { $0.date >= today }.sorted { $0.date < $1.date }.first
    }

    // MARK: Pieces

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(Theme.sans(13, .medium))
                    .foregroundStyle(Theme.muted)
                ScreenTitle(text: "Welcome back, ", accent: state.firstName)
            }
            Spacer()
            NavigationLink {
                ProfileView()
            } label: {
                UserAvatar(size: 50)
            }
            .accessibilityLabel("Your profile")
        }
    }

    private var learningCard: some View {
        let module = state.nextModule
        let progress = Double(completed) / Double(MockData.modules.count)
        return Button {
            state.selectedTab = .journey
        } label: {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your learning path")
                            .font(Theme.sans(12, .medium))
                            .foregroundStyle(Theme.onGreenMuted)
                        Text(module.title)
                            .font(Theme.serif(30, .semibold))
                            .multilineTextAlignment(.leading)
                        Text("Module \(module.id) of \(MockData.modules.count)")
                            .font(Theme.sans(13, .semibold))
                            .foregroundStyle(Theme.goldOnGreen)
                    }
                    Spacer(minLength: 0)
                    GoldArrow()
                }
                HStack(spacing: 12) {
                    ProgressLine(value: progress, track: Theme.greenTrack, fill: Theme.goldOnGreen)
                    Text("\(Int(progress * 100))%")
                        .font(Theme.sans(12, .semibold))
                }
            }
            .greenCard()
        }
        .buttonStyle(.plain)
    }

    private var liveCard: some View {
        let session = MockData.liveSessions[0]
        return Button {
            state.selectedTab = .sessions
        } label: {
            HStack(spacing: 14) {
                FillPhoto(name: session.image, height: 66, width: 66, radius: 16)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(Theme.liveDot)
                            .frame(width: 8, height: 8)
                            .background(Circle().fill(Theme.liveDot.opacity(0.22)).frame(width: 14, height: 14))
                        Text("Live \(session.date.lowercased()), \(session.time)")
                    }
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.red)
                    Text("Confidence Mastery")
                        .font(Theme.serif(22, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("with \(session.host)")
                        .font(Theme.sans(12))
                        .foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
                OutlineArrow()
            }
            .padding(.vertical, 14)
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func bookingCard(_ booking: Booking) -> some View {
        HStack(spacing: 14) {
            FillPhoto(name: MockData.coaches.first { $0.name == booking.coachName }?.image ?? "mia_avatar",
                      height: 66, width: 66, radius: 16)
            VStack(alignment: .leading, spacing: 3) {
                Text("Your 1:1 session")
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.goldText)
                Text("with \(booking.coachName)")
                    .font(Theme.serif(22, .semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(booking.date.formatted(.dateTime.weekday(.wide).month().day())) · \(booking.slot)")
                    .font(Theme.sans(12))
                    .foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
        }
        .whiteCard(padding: 14)
    }

    private func statTile(value: String, unit: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(Theme.serif(46, .semibold))
                    .foregroundStyle(Theme.green)
                Text(unit)
                    .font(Theme.sans(13, .medium))
                    .foregroundStyle(Theme.muted)
            }
            Text(caption)
                .font(Theme.sans(14, .medium))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .whiteCard(padding: 18)
    }

    private var challengeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("Today's challenge", color: Theme.goldText)
            Text(state.todaysChallenge)
                .font(Theme.serif(22, .semibold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if state.challengeDoneToday {
                Label("Done. Proud of you.", systemImage: "checkmark.circle.fill")
                    .font(Theme.sans(14, .semibold))
                    .foregroundStyle(Theme.green)
            } else {
                Button("I did it") {
                    withAnimation { state.completeTodaysChallenge() }
                }
                .buttonStyle(GoldButtonStyle(height: 48, fontSize: 14))
            }
        }
        .whiteCard(padding: 22)
    }

    private var miaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                RoundPhoto(name: "mia_avatar", size: 42)
                SectionLabel("Message from Mia", color: Theme.goldText)
            }
            Text(miaMessage.0)
                .font(Theme.serif(26, .semibold))
                .foregroundStyle(Theme.ink)
            Text(miaMessage.1)
                .font(Theme.sans(15))
                .foregroundStyle(Theme.muted)
                .lineSpacing(4)
            Button {
                state.selectedTab = .mia
            } label: {
                HStack(spacing: 8) {
                    Text("Reply to Mia")
                    Image(systemName: "arrow.right")
                }
                .font(Theme.sans(15, .bold))
                .foregroundStyle(Theme.green)
                .frame(minHeight: 44)
            }
        }
        .whiteCard(padding: 22)
    }
}
