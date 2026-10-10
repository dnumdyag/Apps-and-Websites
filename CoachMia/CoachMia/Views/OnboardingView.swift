import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState

    @State private var step = 0
    @State private var name = ""
    @State private var age = ""
    @State private var status = "Single"
    @State private var goals: Set<String> = []
    @State private var challengeIndex: Int?

    private let totalSteps = 5
    private let statuses = ["Single", "Dating", "In a relationship", "It's complicated"]

    var body: some View {
        VStack(spacing: 0) {
            if step > 0 {
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    switch step {
                    case 0: welcome
                    case 1: aboutYou
                    case 2: goalsStep
                    case 3: challengeStep
                    default: planStep
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)

            footer
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .miaBackground()
        .animation(.easeInOut(duration: 0.25), value: step)
    }

    // MARK: Steps

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer(minLength: 40)
            MiaAvatar(size: 72)
            VStack(alignment: .leading, spacing: 12) {
                Text("Hi, I'm Mia.")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(Theme.text)
                Text("Your personal dating and relationship coach. Together we'll build real confidence, better conversations and connections that last.")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Theme.textSoft)
                    .lineSpacing(4)
            }
            VStack(alignment: .leading, spacing: 16) {
                featureRow("message", "Coach Mia AI, here 24/7")
                featureRow("book", "A learning path made for you")
                featureRow("person.2", "A private community of men growing together")
                featureRow("calendar", "Live sessions, events & 1:1 coaching")
            }
            .miaCard()
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 14) {
            IconBubble(systemName: icon, size: 36)
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.text)
        }
    }

    private var aboutYou: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepTitle("Let's get to know you", "Just the basics. You can change these anytime.")
            field("First name") {
                TextField("", text: $name, prompt: Text("Your name").foregroundColor(Theme.textMuted))
                    .textContentType(.givenName)
            }
            field("Age") {
                TextField("", text: $age, prompt: Text("e.g. 32").foregroundColor(Theme.textMuted))
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
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Theme.text)
                .padding(16)
                .background(Theme.chip.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.border.opacity(0.35)))
        }
    }

    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepTitle("What would you like to work on?", "Choose as many as you like.")
            VStack(spacing: 12) {
                ForEach(MockData.goals, id: \.self) { goal in
                    selectableRow(goal, selected: goals.contains(goal)) {
                        if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
                    }
                }
            }
        }
    }

    private var challengeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepTitle("What feels hardest right now?", "This helps Mia personalise your path.")
            VStack(spacing: 12) {
                ForEach(Array(MockData.challenges.enumerated()), id: \.offset) { index, item in
                    selectableRow(item.label, selected: challengeIndex == index) {
                        challengeIndex = index
                    }
                }
            }
        }
    }

    private var planStep: some View {
        let moduleID = MockData.challenges[challengeIndex ?? 3].moduleID
        let module = MockData.modules.first { $0.id == moduleID } ?? MockData.modules[0]
        return VStack(alignment: .leading, spacing: 24) {
            stepTitle("Your plan is ready, \(name.isEmpty ? "friend" : name)", "Here's where we'll start together.")
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    MiaAvatar(size: 36)
                    Text("Message from Mia")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
                Text("I'm really glad you're here. We'll go at your pace, no pressure. Every small step counts.")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(4)
            }
            .miaCard()

            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Your first module")
                Text(module.title)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Theme.text)
                Text(module.subtitle)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.textSoft)
            }
            .miaCard()

            HStack(spacing: 14) {
                IconBubble(systemName: "gift", size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome gift: 7 days of full membership")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("Explore everything. Cancel anytime.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .miaCard(padding: 18)
        }
    }

    // MARK: Pieces

    private func stepTitle(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.text)
            Text(subtitle)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(.top, 16)
    }

    private func selectableRow(_ text: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? Theme.gold : Theme.textMuted)
            }
            .padding(18)
            .background(
                selected ? Theme.gold.opacity(0.12) : Theme.chip.opacity(0.45),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? Theme.gold.opacity(0.5) : Theme.border.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.chip.opacity(0.6))
                Capsule().fill(Theme.goldFill)
                    .frame(width: geo.size.width * CGFloat(step) / CGFloat(totalSteps - 1))
            }
        }
        .frame(height: 4)
    }

    private var canContinue: Bool {
        switch step {
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: return challengeIndex != nil
        default: return true
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if step == 0 {
                Button {
                    step = 1
                } label: {
                    Label("Continue with Apple", systemImage: "apple.logo")
                }
                .buttonStyle(GoldButtonStyle())
                Button("Continue with email") { step = 1 }
                    .buttonStyle(SoftButtonStyle())
            } else {
                Button(step == totalSteps - 1 ? "Let's begin" : "Continue") {
                    if step == totalSteps - 1 { finish() } else { step += 1 }
                }
                .buttonStyle(GoldButtonStyle())
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)

                Button("Back") { step -= 1 }
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
        }
    }

    private func finish() {
        var p = state.profile
        p.name = name.trimmingCharacters(in: .whitespaces)
        p.age = age
        p.relationshipStatus = status
        p.goals = MockData.goals.filter { goals.contains($0) }
        p.focusModuleID = MockData.challenges[challengeIndex ?? 3].moduleID
        p.isPremium = true // 7 day welcome trial for the demo
        p.hasOnboarded = true
        withAnimation { state.profile = p }
    }
}
