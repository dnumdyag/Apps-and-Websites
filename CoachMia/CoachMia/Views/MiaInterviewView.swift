import SwiftUI

/// The opening interview: after the welcome screen, Mia gets to know the member in a chat.
/// She asks one question at a time, reacts to each answer, then reveals his blind spot.
struct MiaInterviewView: View {
    @EnvironmentObject var state: AppState
    /// For screenshots: how many questions to show as already answered (0 to 5).
    var prefilledAnswers = 0

    private enum Step: Int { case name, age, status, goals, challenge, result }
    private enum Speaker { case mia, member }

    private struct Line: Identifiable {
        let id = UUID()
        let speaker: Speaker
        let text: String
        var isResult = false
    }

    private static let ages = ["Under 25", "25 to 30", "31 to 35", "36 to 40", "41 to 50", "Over 50"]
    private static let statuses = ["Single", "Dating", "In a relationship", "It's complicated"]

    @State private var lines: [Line] = []
    @State private var step: Step = .name
    @State private var miaTyping = false
    @State private var showAnswers = false
    @State private var started = false

    @State private var nameDraft = ""
    @State private var name = ""
    @State private var age = ""
    @State private var status = ""
    @State private var goals: Set<String> = []
    @State private var challengeIndex: Int?
    @FocusState private var nameFocused: Bool

    private var challenge: QuizChallenge { MockData.challenges[challengeIndex ?? 3] }
    private var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        intro
                        ForEach(lines.indices, id: \.self) { index in
                            let line = lines[index]
                            row(line, showAvatar: isLastOfMiaRun(index))
                                .id(line.id)
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                        removal: .opacity))
                        }
                        if miaTyping {
                            HStack(alignment: .bottom, spacing: 8) {
                                RoundPhoto(name: "mia_avatar", size: 28)
                                InterviewTypingBubble()
                                Spacer()
                            }
                                .id("typing")
                                .transition(.opacity)
                        }
                        Color.clear.frame(height: 4).id("end")
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if showAnswers { answerPanel.transition(.move(edge: .bottom).combined(with: .opacity)) }
                }
                .onChange(of: lines.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.35)) { proxy.scrollTo("end", anchor: .bottom) }
                }
                .onChange(of: miaTyping) { _, _ in
                    withAnimation(.easeOut(duration: 0.35)) { proxy.scrollTo("end", anchor: .bottom) }
                }
                .onChange(of: showAnswers) { _, _ in
                    withAnimation(.easeOut(duration: 0.35)) { proxy.scrollTo("end", anchor: .bottom) }
                }
            }
        }
        .screenBackground()
        .onAppear {
            guard !started else { return }
            started = true
            if prefilledAnswers > 0 { prefill() } else { askName() }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    RoundPhoto(name: "mia_avatar", size: 42)
                        .padding(2)
                        .overlay(Circle().strokeBorder(Theme.metalGold, lineWidth: 1.5))
                    Circle()
                        .fill(Theme.online)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Theme.surface, lineWidth: 2.5))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mia")
                        .font(Theme.serif(26, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(step == .result ? "Your plan is ready" : "Getting to know you")
                        .font(Theme.sans(12))
                        .foregroundStyle(Theme.muted)
                        .contentTransition(.opacity)
                }
                Spacer()
                Text("\(min(step.rawValue + 1, 5)) of 5")
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.goldText)
                    .monospacedDigit()
                    .opacity(step == .result ? 0 : 1)
                if step != .result {
                    // Straight into the app with what has been answered so far.
                    Button("Skip") {
                        MiaVoice.shared.stop()
                        finish()
                    }
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.muted)
                    .padding(.leading, 4)
                }
            }
            ProgressLine(value: Double(step.rawValue) / 5, track: Theme.track, fill: Theme.green, height: 3)
                .animation(.easeInOut(duration: 0.5), value: step)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(Theme.surface.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.divider).frame(height: 1) }
    }

    // MARK: Messages

    /// The top of the conversation: Mia's portrait in a gold ring, like the start of a private chat.
    private var intro: some View {
        VStack(spacing: 10) {
            RoundPhoto(name: "mia_avatar", size: 84)
                .padding(4)
                .overlay(Circle().strokeBorder(Theme.metalGold, lineWidth: 2))
                .shadow(color: Theme.green.opacity(0.18), radius: 14, y: 8)
            VStack(spacing: 4) {
                Text("Your first conversation")
                    .font(Theme.serif(22, .semibold))
                    .foregroundStyle(Theme.ink)
                Text("PRIVATE · ABOUT ONE MINUTE")
                    .font(Theme.sans(10, .semibold))
                    .tracking(2)
                    .foregroundStyle(Theme.goldText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private func isLastOfMiaRun(_ index: Int) -> Bool {
        guard lines[index].speaker == .mia, !lines[index].isResult else { return false }
        if index == lines.count - 1 { return !miaTyping }
        return lines[index + 1].speaker != .mia || lines[index + 1].isResult
    }

    @ViewBuilder private func row(_ line: Line, showAvatar: Bool) -> some View {
        if line.isResult {
            resultCard
        } else {
            let mia = line.speaker == .mia
            let shape = UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: mia ? 6 : 20,
                                               bottomTrailingRadius: mia ? 20 : 6, topTrailingRadius: 20,
                                               style: .continuous)
            HStack(alignment: .bottom, spacing: 8) {
                if mia {
                    RoundPhoto(name: "mia_avatar", size: 28)
                        .opacity(showAvatar ? 1 : 0)
                } else {
                    Spacer(minLength: 60)
                }
                Text(line.text)
                    .font(Theme.sans(15))
                    .lineSpacing(3)
                    .foregroundStyle(mia ? Theme.ink : Theme.onGreen)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        if mia {
                            shape.fill(Theme.surface)
                                .shadow(color: Theme.green.opacity(0.07), radius: 8, y: 3)
                        } else {
                            shape.fill(Theme.greenFill)
                                .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.2), .clear],
                                                                           startPoint: .top, endPoint: .bottom), lineWidth: 1))
                        }
                    }
                if mia { Spacer(minLength: 60) }
            }
        }
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR BLIND SPOT")
                .font(Theme.sans(11, .semibold))
                .tracking(2)
                .foregroundStyle(Theme.goldOnGreen)
            Text(challenge.blindSpot)
                .font(Theme.serif(30, .semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text("Your plan starts with \(MockData.modules.first { $0.id == challenge.moduleID }?.title ?? "your first module").")
                .font(Theme.sans(13))
                .foregroundStyle(Theme.onGreenMuted)
        }
        .greenCard(padding: 22)
        .padding(.vertical, 6)
    }

    // MARK: Answers

    @ViewBuilder private var answerPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch step {
            case .name:
                HStack(spacing: 10) {
                    TextField("", text: $nameDraft, prompt: Text("Your first name").foregroundColor(Theme.faint))
                        .font(Theme.sans(16))
                        .foregroundStyle(Theme.ink)
                        .textContentType(.givenName)
                        .submitLabel(.send)
                        .focused($nameFocused)
                        .onSubmit(submitName)
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .background(Theme.surface, in: Capsule())
                        .overlay(Capsule().stroke(Theme.outline, lineWidth: 1.5))
                    Button(action: submitName) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(Theme.goldInk)
                            .frame(width: 52, height: 52)
                            .background(Theme.goldFill, in: Circle())
                    }
                    .disabled(trimmedName.isEmpty)
                    .opacity(trimmedName.isEmpty ? 0.5 : 1)
                    .accessibilityLabel("Send")
                }
            case .age:
                chips(Self.ages) { answerAge($0) }
            case .status:
                chips(Self.statuses) { answerStatus($0) }
            case .goals:
                FlowLayout {
                    ForEach(MockData.goals, id: \.self) { goal in
                        Button(goal) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
                            }
                        }
                        .buttonStyle(ChipButtonStyle(selected: goals.contains(goal)))
                    }
                }
                Button("That's everything", action: answerGoals)
                    .buttonStyle(GoldButtonStyle(height: 48, fontSize: 15))
                    .disabled(goals.isEmpty)
                    .opacity(goals.isEmpty ? 0.5 : 1)
            case .challenge:
                VStack(spacing: 8) {
                    ForEach(MockData.challenges.indices, id: \.self) { index in
                        Button { answerChallenge(index) } label: {
                            HStack {
                                Text(MockData.challenges[index].label)
                                    .font(Theme.sans(15, .medium))
                                    .foregroundStyle(Theme.ink)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.green)
                            }
                            .padding(.horizontal, 18)
                            .frame(minHeight: 50)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.outline, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .result:
                Button(action: finish) {
                    HStack(spacing: 9) {
                        Text("Begin my journey")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(GoldButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 10)
        .background {
            LinearGradient(stops: [.init(color: Theme.background.opacity(0), location: 0),
                                   .init(color: Theme.background, location: 0.22)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func chips(_ options: [String], action: @escaping (String) -> Void) -> some View {
        FlowLayout {
            ForEach(options, id: \.self) { option in
                Button(option) { action(option) }
                    .buttonStyle(ChipButtonStyle())
            }
        }
    }

    private var trimmedName: String { nameDraft.trimmingCharacters(in: .whitespacesAndNewlines) }

    // MARK: The conversation

    private func askName() {
        miaSays(["Hi, I'm Mia.",
                 "Before we begin, I'd love to get to know you a little. It takes about a minute.",
                 "What should I call you?"])
    }

    private func submitName() {
        guard showAnswers, !trimmedName.isEmpty else { return }
        name = trimmedName
        nameFocused = false
        memberSays(name)
        advance(to: .age)
        miaSays(["Lovely to meet you, \(firstName).", "How old are you?"])
    }

    private func answerAge(_ answer: String) {
        guard showAnswers else { return }
        age = answer
        memberSays(answer)
        advance(to: .status)
        miaSays(["Thank you.", "And where are you in love right now?"])
    }

    private func answerStatus(_ answer: String) {
        guard showAnswers else { return }
        status = answer
        memberSays(answer)
        advance(to: .goals)
        let reaction: String
        switch answer {
        case "Single": reaction = "A clean slate. That's a strong place to start."
        case "Dating": reaction = "Good, you're already out there. Let's make it feel easier."
        case "In a relationship": reaction = "Then we'll work on making it deeper and lasting."
        default: reaction = "I understand. We'll untangle it together, one step at a time."
        }
        miaSays([reaction, "What would you most like to change? Choose everything that feels true."])
    }

    private func answerGoals() {
        guard showAnswers, !goals.isEmpty else { return }
        let picked = MockData.goals.filter { goals.contains($0) }
        memberSays(picked.joined(separator: ", "))
        advance(to: .challenge)
        let reaction = picked.count == 1 ? "Clear and focused. I like that." : "That's honest. We'll take it one step at a time."
        miaSays([reaction, "Last one, and be honest with me.", "What feels hardest right now?"])
    }

    private func answerChallenge(_ index: Int) {
        guard showAnswers else { return }
        challengeIndex = index
        memberSays(MockData.challenges[index].label)
        advance(to: .result)
        miaSays(["Thank you for trusting me with that, \(firstName).", "I think I can see it."], thinking: 1.6) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                lines.append(Line(speaker: .mia, text: "", isResult: true))
            }
        }
    }

    private func finish() {
        var p = state.profile
        p.name = name
        p.age = age
        p.relationshipStatus = status.isEmpty ? "Single" : status
        p.goals = MockData.goals.filter { goals.contains($0) }
        p.focusModuleID = challenge.moduleID
        p.blindSpot = challenge.blindSpot
        p.isPremium = true // 7 day welcome trial for the demo
        p.joinedAt = Date()
        p.hasOnboarded = true
        state.profile = p
    }

    // MARK: Pacing

    private func advance(to next: Step) {
        withAnimation(.easeInOut(duration: 0.25)) {
            showAnswers = false
            step = next
        }
    }

    private func memberSays(_ text: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            lines.append(Line(speaker: .member, text: text))
        }
    }

    /// Mia types each message in turn (longer messages take a little longer), then the answer
    /// options slide up.
    private func miaSays(_ texts: [String], thinking: Double = 0, then: (() -> Void)? = nil) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            for (i, text) in texts.enumerated() {
                withAnimation(.easeOut(duration: 0.2)) { miaTyping = true }
                let pause = min(1.4, 0.55 + Double(text.count) * 0.012) + (i == texts.count - 1 ? thinking : 0)
                try? await Task.sleep(nanoseconds: UInt64(pause * 1_000_000_000))
                withAnimation(.easeOut(duration: 0.15)) { miaTyping = false }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    lines.append(Line(speaker: .mia, text: text))
                }
                // When Mia has a recording of the line, she says it before typing the next one.
                let spoken = MiaVoice.shared.say(text)
                try? await Task.sleep(nanoseconds: UInt64((spoken + 0.25) * 1_000_000_000))
            }
            then?()
            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { showAnswers = true }
            if step == .name {
                try? await Task.sleep(nanoseconds: 450_000_000)
                nameFocused = true
            }
        }
    }

    /// Screenshots: show the first answers as already given, then carry on live.
    private func prefill() {
        lines = [Line(speaker: .mia, text: "Hi, I'm Mia."),
                 Line(speaker: .mia, text: "Before we begin, I'd love to get to know you a little. It takes about a minute."),
                 Line(speaker: .mia, text: "What should I call you?"),
                 Line(speaker: .member, text: "James")]
        name = "James"
        var next: Step = .age
        if prefilledAnswers >= 2 {
            age = "31 to 35"
            lines += [Line(speaker: .mia, text: "Lovely to meet you, James."), Line(speaker: .mia, text: "How old are you?"),
                      Line(speaker: .member, text: age)]
            next = .status
        }
        if prefilledAnswers >= 3 {
            status = "Single"
            lines += [Line(speaker: .mia, text: "Thank you."), Line(speaker: .mia, text: "And where are you in love right now?"),
                      Line(speaker: .member, text: status),
                      Line(speaker: .mia, text: "A clean slate. That's a strong place to start."),
                      Line(speaker: .mia, text: "What would you most like to change? Choose everything that feels true.")]
            next = .goals
        }
        if prefilledAnswers >= 4 {
            goals = ["Better conversations", "Attract the right partner"]
            lines += [Line(speaker: .member, text: "Attract the right partner, Better conversations"),
                      Line(speaker: .mia, text: "That's honest. We'll take it one step at a time."),
                      Line(speaker: .mia, text: "Last one, and be honest with me."),
                      Line(speaker: .mia, text: "What feels hardest right now?")]
            next = .challenge
        }
        if prefilledAnswers >= 5 {
            challengeIndex = 0
            lines += [Line(speaker: .member, text: MockData.challenges[0].label),
                      Line(speaker: .mia, text: "Thank you for trusting me with that, James."),
                      Line(speaker: .mia, text: "I think I can see it."),
                      Line(speaker: .mia, text: "", isResult: true)]
            next = .result
        }
        step = next
        showAnswers = true
    }
}

/// Mia's typing dots, gold and green, gently rising in turn.
private struct InterviewTypingBubble: View {
    @State private var on = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i == 1 ? Theme.goldDot : Theme.green)
                    .frame(width: 7, height: 7)
                    .offset(y: on ? -3 : 2)
                    .animation(.easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15), value: on)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(Theme.surface, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 6,
                                                              bottomTrailingRadius: 20, topTrailingRadius: 20,
                                                              style: .continuous))
        .onAppear { on = true }
    }
}
