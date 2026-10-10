import SwiftUI
import AVKit

struct JourneyView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(title: "Your journey", subtitle: "Explore at your own pace. There's no rush.")

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Where you are")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Theme.textMuted)
                        Text(state.nextModule.title)
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(Theme.text)
                        ProgressView(value: Double(state.profile.completedModules.count), total: Double(MockData.modules.count))
                            .tint(Theme.gold)
                        Text("\(state.profile.completedModules.count) of \(MockData.modules.count) modules completed")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .miaCard()
                    .padding(.bottom, 8)

                    ForEach(MockData.modules) { module in
                        moduleCard(module)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .miaBackground()
            .navigationDestination(for: Int.self) { id in
                if let module = MockData.modules.first(where: { $0.id == id }) {
                    ModuleDetailView(module: module)
                }
            }
        }
    }

    private func moduleCard(_ module: Module) -> some View {
        let unlocked = state.isUnlocked(module)
        let completed = state.profile.completedModules.contains(module.id)
        let isCurrent = module.id == state.nextModule.id

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Module \(module.id) · \(module.minutes) min")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                    Text(module.title)
                        .font(.system(size: 19, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text(module.subtitle)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
                Spacer()
                if completed {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.gold)
                } else if !unlocked {
                    Image(systemName: "lock").foregroundStyle(Theme.textMuted)
                }
            }

            if unlocked {
                NavigationLink(value: module.id) {
                    Text(completed ? "Revisit if you wish" : isCurrent ? "Continue exploring" : "Begin when ready")
                }
                .buttonStyle(isCurrent && !completed ? AnyButtonStyle(GoldButtonStyle()) : AnyButtonStyle(SoftButtonStyle()))
            } else {
                Text("Opens after the previous module, or with full membership")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .miaCard(padding: 26)
        .opacity(unlocked ? 1 : 0.45)
    }
}

/// Lets us pick between two button styles with a ternary.
struct AnyButtonStyle: ButtonStyle {
    private let make: (ButtonStyleConfiguration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        make = { AnyView(style.makeBody(configuration: $0)) }
    }

    func makeBody(configuration: Configuration) -> some View {
        make(configuration)
    }
}

struct ModuleDetailView: View {
    @EnvironmentObject var state: AppState
    let module: Module
    @State private var player: AVPlayer?

    private var completed: Bool { state.profile.completedModules.contains(module.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Module \(module.id) · \(module.minutes) min")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                    Text(module.title)
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text(module.subtitle)
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }

                videoBlock

                Text(module.summary)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(5)

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel("Key takeaways")
                    ForEach(module.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.gold)
                                .padding(.top, 3)
                            Text(point)
                                .font(.system(size: 15, weight: .light))
                                .foregroundStyle(Theme.text)
                        }
                    }
                }
                .miaCard()

                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel("Your exercise")
                    Text(module.exercise)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Theme.text)
                        .lineSpacing(3)
                }
                .miaCard()

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
                    Label("Ask Mia about this", systemImage: "message")
                }
                .buttonStyle(SoftButtonStyle())
            }
            .padding(24)
        }
        .miaBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { player?.pause() }
    }

    private var videoBlock: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                LinearGradient(colors: [Theme.card1, Theme.bgTop], startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(spacing: 10) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 54, weight: .thin))
                        .foregroundStyle(Theme.gold)
                    Text("Video lesson with Mia")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Theme.border.opacity(0.3)))
        .onTapGesture {
            if player == nil {
                let p = AVPlayer(url: MockData.sampleVideoURL)
                player = p
                p.play()
            }
        }
    }
}
