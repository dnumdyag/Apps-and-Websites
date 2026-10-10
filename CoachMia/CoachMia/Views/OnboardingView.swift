import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState

    @State private var step = 0
    @State private var name = ""
    @State private var age = ""
    @State private var status = "Single"
    @State private var goals: Set<String> = []
    @State private var challengeIndex: Int?

    private let lastStep = 4
    private let statuses = ["Single", "Dating", "In a relationship", "It's complicated"]

    private var challenge: QuizChallenge {
        MockData.challenges[challengeIndex ?? 3]
    }

    var body: some View {
        VStack(spacing: 0) {
            logoHeader

            if step == 0 || step == lastStep {
                heroScreen
            } else {
                formScreen
            }
        }
        .screenBackground()
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    // MARK: Header

    private var logoHeader: some View {
        Text("Coach Mia")
            .font(Theme.script(46))
            .foregroundStyle(Theme.goldText)
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(Theme.surface)
            .overlay(alignment: .bottom) { Rectangle().fill(Theme.divider).frame(height: 1) }
    }

    // MARK: Welcome + result (the design's hero layout)

    private var heroScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero

                if step == 0 {
                    ScreenTitle(text: "Let's find your blind spot. ", accent: "Then we work on it.")
                    Text("A few quick questions so I can build a plan around you. It takes about a minute.")
                        .font(Theme.sans(15))
                        .foregroundStyle(Theme.muted)
                        .lineSpacing(3)
                } else {
                    ScreenTitle(text: "You've found your blind spot. ", accent: "Now we work on it.")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("YOUR QUIZ RESULT")
                            .font(Theme.sans(11, .semibold))
                            .tracking(2)
                            .foregroundStyle(Theme.goldOnGreen)
                        Text(challenge.blindSpot)
                            .font(Theme.serif(26, .semibold))
                        Text("Your plan is built around this pattern.")
                            .font(Theme.sans(13))
                            .foregroundStyle(Theme.onGreenMuted)
                    }
                    .greenCard(padding: 20)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if step == 0 {
                    Button { step = 1 } label: {
                        Label("Continue with Apple", systemImage: "apple.logo")
                    }
                    .buttonStyle(GoldButtonStyle())
                    Button("Continue with email") { step = 1 }
                        .buttonStyle(OutlineButtonStyle(fullWidth: true, height: 52))
                } else {
                    Button(action: finish) {
                        HStack(spacing: 9) {
                            Text("Begin my journey")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(GoldButtonStyle())
                }
                Text("CONSCIOUS LOVE · DATING · SELF-AWARENESS")
                    .font(Theme.sans(9.5, .semibold))
                    .tracking(2)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Theme.background)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .frame(height: step == 0 ? 340 : 300)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    Image("mia_hero").resizable().scaledToFill()
                }
                .clipped()
            LinearGradient(colors: [Color(hex: 0x081813, opacity: 0), Color(hex: 0x081813, opacity: 0.9)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 150)
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, I'm Mia")
                    .font(Theme.serif(30, .medium, italic: true))
                    .foregroundStyle(Color(hex: 0xF0DCA0))
                Text("DATING COACH · 150+ PEOPLE COACHED")
                    .font(Theme.sans(10, .semibold))
                    .tracking(1.8)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    // MARK: Question steps

    private var formScreen: some View {
        VStack(spacing: 0) {
            ProgressLine(value: Double(step) / Double(lastStep), track: Theme.track, fill: Theme.green)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch step {
                    case 1: aboutYou
                    case 2: goalsStep
                    default: challengeStep
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)

            VStack(spacing: 6) {
                Button(step == 3 ? "See my result" : "Continue") { step += 1 }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1 : 0.5)
                Button("Back") { step -= 1 }
                    .font(Theme.sans(14, .medium))
                    .foregroundStyle(Theme.muted)
                    .frame(minHeight: 44)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    private var aboutYou: some View {
        VStack(alignment: .leading, spacing: 24) {
            ScreenHeader(title: "Let's get to ", accent: "know you", subtitle: "Just the basics. You can change these anytime.")
            field("First name") {
                TextField("", text: $name, prompt: Text("Your name").foregroundColor(Theme.faint))
                    .textContentType(.givenName)
            }
            field("Age") {
                TextField("", text: $age, prompt: Text("e.g. 32").foregroundColor(Theme.faint))
                    .keyboardType(.numberPad)
            }
            VStack(alignment: .leading, spacing: 12) {
                SectionLabel("Relationship status")
                FlowLayout {
                    ForEach(statuses, id: \.self) { s in
                        Button(s) { status = s }
                            .buttonStyle(ChipButtonStyle(selected: status == s))
                    }
                }
            }
        }
    }

    private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(label)
            content()
                .font(Theme.sans(16))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 20)
                .frame(height: 52)
                .background(Theme.surface, in: Capsule())
                .overlay(Capsule().stroke(Theme.outline, lineWidth: 1.5))
        }
    }

    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            ScreenHeader(title: "What would you like to ", accent: "work on?", subtitle: "Choose as many as you like.")
            VStack(spacing: 10) {
                ForEach(MockData.goals, id: \.self) { goal in
                    selectableRow(goal, selected: goals.contains(goal)) {
                        if goals.contains(goal) { _ = goals.remove(goal) } else { _ = goals.insert(goal) }
                    }
                }
            }
        }
    }

    private var challengeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            ScreenHeader(title: "What feels ", accent: "hardest right now?", subtitle: "Be honest. This is how we find your blind spot.")
            VStack(spacing: 10) {
                ForEach(MockData.challenges.indices, id: \.self) { index in
                    selectableRow(MockData.challenges[index].label, selected: challengeIndex == index) {
                        challengeIndex = index
                    }
                }
            }
        }
    }

    private func selectableRow(_ text: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(Theme.sans(15, .medium))
                    .foregroundStyle(selected ? Theme.onGreen : Theme.ink)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(selected ? Theme.goldOnGreen : Theme.outline)
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 58)
            .background(selected ? Theme.green : Theme.surface,
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var canContinue: Bool {
        switch step {
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: return challengeIndex != nil
        default: return true
        }
    }

    private func finish() {
        var p = state.profile
        p.name = name.trimmingCharacters(in: .whitespaces)
        p.age = age
        p.relationshipStatus = status
        p.goals = MockData.goals.filter { goals.contains($0) }
        p.focusModuleID = challenge.moduleID
        p.blindSpot = challenge.blindSpot
        p.isPremium = true // 7 day welcome trial for the demo
        p.joinedAt = Date()
        p.hasOnboarded = true
        state.profile = p
    }
}
