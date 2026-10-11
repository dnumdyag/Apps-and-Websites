import SwiftUI

struct OnboardingView: View {
    @State private var interviewing: Bool
    private let prefilledAnswers: Int

    /// startStep 0 is the welcome screen; 1 to 4 open Mia's interview (for screenshots, 2 to 4
    /// start part way through).
    init(startStep: Int = 0) {
        _interviewing = State(initialValue: startStep > 0)
        prefilledAnswers = [0, 0, 3, 4, 5][max(0, min(startStep, 4))]
    }

    var body: some View {
        ZStack {
            if interviewing {
                MiaInterviewView(prefilledAnswers: prefilledAnswers)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            } else {
                VStack(spacing: 0) {
                    logoHeader
                    heroScreen
                }
                .screenBackground()
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: interviewing)
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

    // MARK: Welcome (the design's hero layout)

    private var heroScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                ScreenTitle(text: "Let's find your blind spot. ", accent: "Then we work on it.", size: 34)
                Text("I'll ask you a few questions so I can build a plan around you. It takes about a minute.")
                    .font(Theme.sans(15))
                    .foregroundStyle(Theme.muted)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button { interviewing = true } label: {
                    Label("Continue with Apple", systemImage: "apple.logo")
                }
                .buttonStyle(GoldButtonStyle())
                Button("Continue with email") { interviewing = true }
                    .buttonStyle(OutlineButtonStyle(fullWidth: true, height: 52))
                Text("CONSCIOUS LOVE · DATING · SELF-AWARENESS")
                    .font(Theme.sans(10, .semibold))
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
                .frame(height: 270)
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
}
