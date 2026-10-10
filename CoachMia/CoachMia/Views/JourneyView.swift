import SwiftUI
import AVKit

struct JourneyView: View {
    @EnvironmentObject var state: AppState

    @State private var bookingCoach: Coach?
    @State private var showMembership = false
    @State private var retreatAlert: Retreat?

    private var completed: Int { state.profile.completedModules.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ScreenHeader(title: "Your ", accent: "journey", subtitle: "Explore at your own pace. There's no rush.")
                    whereYouAre
                    VStack(alignment: .leading, spacing: 16) {
                        SectionLabel("All modules")
                        VStack(spacing: 0) {
                            ForEach(MockData.modules) { module in
                                moduleRow(module, isLast: module.id == MockData.modules.last?.id)
                            }
                        }
                    }
                    moreSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { id in
                if let module = MockData.modules.first(where: { $0.id == id }) {
                    ModuleDetailView(module: module)
                }
            }
            .sheet(item: $bookingCoach) { coach in
                BookingView(initialCoachID: coach.id).environmentObject(state)
            }
            .sheet(isPresented: $showMembership) {
                MembershipView().environmentObject(state)
            }
            .alert(item: $retreatAlert) { retreat in
                Alert(
                    title: Text(retreat.title),
                    message: Text("Thanks for your interest! A secure payment link for your \(Config.currency)\(retreat.price.formatted()) place will be sent to you. (Simulated in this preview.)"),
                    dismissButton: .default(Text("Lovely"))
                )
            }
        }
    }

    // MARK: Where you are

    private var whereYouAre: some View {
        let next = state.nextModule
        return VStack(alignment: .leading, spacing: 16) {
            Text("WHERE YOU ARE · MODULE \(next.id) OF \(MockData.modules.count)")
                .font(Theme.sans(11, .semibold))
                .tracking(2)
                .foregroundStyle(Theme.goldOnGreen)
            VStack(alignment: .leading, spacing: 4) {
                Text(next.title)
                    .font(Theme.serif(30, .semibold))
                Text(next.subtitle)
                    .font(Theme.sans(14))
                    .foregroundStyle(Theme.onGreenMuted)
            }
            HStack(spacing: 4) {
                ForEach(MockData.modules) { module in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(state.profile.completedModules.contains(module.id) ? Theme.goldOnGreen : Theme.greenTrack)
                        .frame(height: 6)
                }
            }
            HStack {
                Text("\(completed) of \(MockData.modules.count) complete")
                    .foregroundStyle(Theme.onGreenMuted)
                Spacer()
                Text("Next: \(next.minutes) min")
                    .foregroundStyle(Theme.goldOnGreen)
            }
            .font(Theme.sans(12.5, .semibold))
            NavigationLink(value: next.id) {
                Text("Continue exploring")
            }
            .buttonStyle(GoldButtonStyle(height: 52))
        }
        .greenCard()
    }

    // MARK: Timeline

    private func moduleRow(_ module: Module, isLast: Bool) -> some View {
        let unlocked = state.isUnlocked(module)
        let done = state.profile.completedModules.contains(module.id)
        let current = module.id == state.nextModule.id && !done

        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                marker(module, unlocked: unlocked, done: done, current: current)
                if !isLast {
                    Rectangle()
                        .fill(done ? Color(hex: 0xD4B066) : Theme.track)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 36)

            Group {
                if current {
                    VStack(alignment: .leading, spacing: 14) {
                        moduleText(module, status: "In progress", statusColor: Theme.green, dim: false)
                        NavigationLink(value: module.id) { Text("Continue exploring") }
                            .buttonStyle(GoldButtonStyle(height: 46, fontSize: 14))
                    }
                    .whiteCard(padding: 18)
                } else if done {
                    NavigationLink(value: module.id) {
                        moduleText(module, status: "Completed", statusColor: Theme.goldText, dim: false)
                    }
                    .buttonStyle(.plain)
                } else if unlocked {
                    HStack(alignment: .center, spacing: 12) {
                        moduleText(module, status: "Not started", statusColor: Theme.muted, dim: false)
                        Spacer(minLength: 0)
                        NavigationLink(value: module.id) { Text("Begin") }
                            .buttonStyle(OutlineButtonStyle())
                    }
                } else {
                    moduleText(module, status: "Opens after previous modules", statusColor: Theme.faint, dim: true)
                }
            }
            .padding(.bottom, isLast ? 0 : 22)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func marker(_ module: Module, unlocked: Bool, done: Bool, current: Bool) -> some View {
        if done {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.goldInk)
                .frame(width: 36, height: 36)
                .background(Theme.goldFill, in: Circle())
        } else if current {
            Text(String(format: "%02d", module.id))
                .font(Theme.sans(12.5, .bold))
                .foregroundStyle(Theme.onGreen)
                .frame(width: 36, height: 36)
                .background(Theme.green, in: Circle())
        } else if unlocked {
            Text(String(format: "%02d", module.id))
                .font(Theme.sans(12.5, .semibold))
                .foregroundStyle(Color(hex: 0x3F4C45))
                .frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color(hex: 0x8C9A92), lineWidth: 1.5))
        } else {
            Image(systemName: "lock")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.faint)
                .frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color(hex: 0x9AA79F), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])))
        }
    }

    private func moduleText(_ module: Module, status: String, statusColor: Color, dim: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(module.title)
                .font(Theme.serif(22, .semibold))
                .foregroundStyle(dim ? Theme.faint : Theme.ink)
            Text(module.subtitle)
                .font(Theme.sans(13.5))
                .foregroundStyle(dim ? Theme.faint : Theme.muted)
            Text(status)
                .font(Theme.sans(12, .semibold))
                .foregroundStyle(statusColor)
                .padding(.top, 2)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: More

    private var moreSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                SectionLabel("More", color: Theme.goldText)
                ScreenTitle(text: "Deepen your ", accent: "journey", size: 34)
                Text("When you're ready for more support")
                    .font(Theme.sans(15))
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 12)

            membershipCard

            VStack(alignment: .leading, spacing: 14) {
                sectionTitle("Private sessions", "Personal time with a coach when you need deeper support")
                ForEach(MockData.coaches) { coach in
                    coachCard(coach)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                sectionTitle("Retreats", "Immersive experiences when you're ready")
                ForEach(MockData.retreats) { retreat in
                    retreatCard(retreat)
                }
            }

            questionsCard
        }
    }

    private func sectionTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.serif(28, .semibold))
                .foregroundStyle(Theme.ink)
            Text(subtitle)
                .font(Theme.sans(14.5))
                .foregroundStyle(Theme.muted)
        }
    }

    private var membershipCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("FULL MEMBERSHIP", systemImage: "crown")
                .font(Theme.sans(11, .semibold))
                .tracking(2)
                .foregroundStyle(Theme.goldCardInk)
            Text("Everything available to support your growth")
                .font(Theme.serif(30, .semibold))
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(MockData.premiumFeatures, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 22, height: 22)
                            .background(Color(hex: 0x14261E, opacity: 0.14), in: Circle())
                        Text(feature)
                            .font(Theme.sans(14.5, .medium))
                    }
                }
            }
            Text("1,842 men exploring together")
                .font(Theme.sans(13, .medium))
                .foregroundStyle(Theme.goldCardInk)
            Button(state.profile.isPremium ? "You're a full member" : "Explore membership") {
                showMembership = true
            }
            .buttonStyle(DarkButtonStyle())
        }
        .goldCard()
    }

    private func coachCard(_ coach: Coach) -> some View {
        HStack(alignment: .top, spacing: 14) {
            FillPhoto(name: coach.image, height: 96, width: 84, radius: 16)
            VStack(alignment: .leading, spacing: 3) {
                Text(coach.name)
                    .font(Theme.sans(15.5, .bold))
                    .foregroundStyle(Theme.ink)
                Text(coach.specialty)
                    .font(Theme.sans(13))
                    .foregroundStyle(Theme.muted)
                Text("\(coach.sessions.formatted()) sessions")
                    .font(Theme.sans(12))
                    .foregroundStyle(Theme.muted)
                HStack(alignment: .center) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Config.currency)\(coach.price)")
                            .font(Theme.serif(24, .semibold))
                            .foregroundStyle(Theme.ink)
                        Text("/ session")
                            .font(Theme.sans(12))
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer(minLength: 0)
                    Button("Book") { bookingCoach = coach }
                        .buttonStyle(OutlineButtonStyle())
                }
                .padding(.top, 4)
            }
        }
        .whiteCard(padding: 14)
    }

    private func retreatCard(_ retreat: Retreat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                FillPhoto(name: retreat.image, height: 170)
                if retreat.spots <= 5 {
                    PhotoBadge(text: "\(retreat.spots) spots left")
                        .padding(14)
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(retreat.title)
                    .font(Theme.serif(24, .semibold))
                    .foregroundStyle(Theme.ink)
                VStack(alignment: .leading, spacing: 4) {
                    Label(retreat.location, systemImage: "mappin.and.ellipse")
                    Label(retreat.dates, systemImage: "calendar")
                }
                .font(Theme.sans(13.5))
                .foregroundStyle(Theme.muted)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Investment")
                            .font(Theme.sans(12))
                            .foregroundStyle(Theme.muted)
                        Text("\(Config.currency)\(retreat.price.formatted())")
                            .font(Theme.serif(28, .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    Spacer()
                    Button("Learn more") { retreatAlert = retreat }
                        .buttonStyle(GoldButtonStyle(height: 46, fontSize: 14))
                        .frame(width: 140)
                }
            }
            .padding(20)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var questionsCard: some View {
        VStack(spacing: 8) {
            Text("Questions?")
                .font(Theme.serif(24, .semibold))
                .foregroundStyle(Theme.ink)
            Text("We're here if you need guidance")
                .font(Theme.sans(14.5))
                .foregroundStyle(Theme.muted)
            if let url = URL(string: "mailto:\(Config.supportEmail)") {
                Link(destination: url) {
                    Text("Reach out")
                        .font(Theme.sans(14, .semibold))
                        .foregroundStyle(Theme.green)
                        .padding(.horizontal, 22)
                        .frame(minHeight: 44)
                        .overlay(Capsule().stroke(Theme.green, lineWidth: 1.5))
                }
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color(hex: 0xAEBBB2), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }
}

// MARK: - Module detail

struct ModuleDetailView: View {
    @EnvironmentObject var state: AppState
    let module: Module
    @State private var player: AVPlayer?

    private var completed: Bool { state.profile.completedModules.contains(module.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionLabel("Module \(module.id) · \(module.minutes) min", color: Theme.goldText)
                    Text(module.title)
                        .font(Theme.serif(38, .medium))
                        .foregroundStyle(Theme.ink)
                    Text(module.subtitle)
                        .font(Theme.sans(15))
                        .foregroundStyle(Theme.muted)
                }

                videoBlock

                Text(module.summary)
                    .font(Theme.sans(15.5))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(5)

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel("Key takeaways")
                    ForEach(module.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.goldInk)
                                .frame(width: 22, height: 22)
                                .background(Theme.goldFill, in: Circle())
                            Text(point)
                                .font(Theme.sans(14.5, .medium))
                                .foregroundStyle(Theme.ink)
                        }
                    }
                }
                .whiteCard(padding: 22)

                VStack(alignment: .leading, spacing: 10) {
                    Text("YOUR EXERCISE")
                        .font(Theme.sans(11, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.goldOnGreen)
                    Text(module.exercise)
                        .font(Theme.serif(22, .semibold))
                }
                .greenCard()

                Button {
                    withAnimation { state.toggleComplete(module) }
                } label: {
                    Label(completed ? "Completed" : "Mark as completed",
                          systemImage: completed ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(GoldButtonStyle())

                Button {
                    state.pendingMiaPrompt = "I'm working on \"\(module.title)\". Can you help me apply it to my situation?"
                    state.selectedTab = .mia
                } label: {
                    Label("Ask Mia about this", systemImage: "bubble.left")
                }
                .buttonStyle(OutlineButtonStyle(fullWidth: true, height: 52))
            }
            .padding(24)
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { player?.pause() }
    }

    private var videoBlock: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                FillPhoto(name: "mia_hero", height: 210)
                LinearGradient(colors: [Color(hex: 0x081813, opacity: 0), Color(hex: 0x081813, opacity: 0.8)],
                               startPoint: .center, endPoint: .bottom)
                // Kept along the bottom edge so nothing sits on Mia's face.
                HStack(spacing: 12) {
                    Text("Video lesson with Mia")
                        .font(Theme.sans(13, .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.goldInk)
                        .frame(width: 50, height: 50)
                        .background(Theme.goldFill, in: Circle())
                }
                .padding(16)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .onTapGesture {
            if player == nil {
                let p = AVPlayer(url: MockData.sampleVideoURL)
                player = p
                p.play()
            }
        }
    }
}
