import SwiftUI

/// A new member's first minute: the splash, then Mia's interview.
struct OnboardingView: View {
    private enum Phase { case splash, interview }

    @State private var phase: Phase
    private let prefilledAnswers: Int

    /// startStep 0 opens with the splash; 1 to 4 open Mia's interview straight away (for
    /// screenshots, 2 to 4 start part way through).
    init(startStep: Int = 0) {
        _phase = State(initialValue: startStep > 0 ? .interview : .splash)
        prefilledAnswers = [0, 0, 3, 4, 5][max(0, min(startStep, 4))]
    }

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView { phase = .interview }
                    .transition(.opacity)
            case .interview:
                MiaInterviewView(prefilledAnswers: prefilledAnswers)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: phase)
    }
}
