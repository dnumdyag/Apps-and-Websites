import SwiftUI

// The full-membership card and the "You're a full member" button: gold with a gentle wash of
// green so the card has depth instead of reading flat, and a member button that stands out.

extension View {
    /// Gold membership card with soft green light mixed in, a bright rim and a lifted shadow.
    func membershipCard(padding: CGFloat = 24, radius: CGFloat = 26) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Theme.goldInk)
            .background {
                ZStack {
                    shape.fill(Theme.goldCardFill)
                    // A gentle wash of green rising from the lower left.
                    shape.fill(RadialGradient(colors: [Theme.green.opacity(0.32), Theme.green.opacity(0)],
                                              center: .bottomLeading, startRadius: 10, endRadius: 340))
                    // A softer green echo in the top right corner.
                    shape.fill(RadialGradient(colors: [Theme.greenTrack.opacity(0.18), .clear],
                                              center: .topTrailing, startRadius: 0, endRadius: 200))
                    // Light falling across the top edge.
                    shape.fill(LinearGradient(colors: [.white.opacity(0.32), .clear],
                                              startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.45)))
                    shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.75), Theme.goldDot.opacity(0.35)],
                                                      startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                }
                .shadow(color: Theme.green.opacity(0.22), radius: 20, y: 12)
            }
    }
}

/// "You're a full member": a deep green pill with a gold seal, gold rim, soft glow and a slow
/// gold shine that crosses it every few seconds.
struct MemberButtonStyle: ButtonStyle {
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.goldOnGreen)
            configuration.label
        }
        .font(Theme.sans(15, .bold))
        .foregroundStyle(Theme.onGreen)
        .padding(.horizontal, 22)
        .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: fullWidth ? 52 : 44)
        .background {
            Capsule()
                .fill(LinearGradient(colors: [Theme.green, Theme.greenDeep], startPoint: .top, endPoint: .bottom))
                .overlay(Capsule().fill(LinearGradient(colors: [.white.opacity(0.2), .clear],
                                                       startPoint: .top, endPoint: .center)))
                .overlay(MemberShine())
                .overlay(Capsule().strokeBorder(LinearGradient(colors: [Theme.goldOnGreen, Theme.goldDot.opacity(0.6)],
                                                               startPoint: .top, endPoint: .bottom), lineWidth: 1.4))
        }
        .shadow(color: Theme.greenDeep.opacity(0.35), radius: 12, y: 6)
        .shadow(color: Theme.goldDot.opacity(0.3), radius: 4)
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// A band of gold light that sweeps across the button, pauses, and sweeps again.
private struct MemberShine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var position: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(colors: [.clear, Theme.goldOnGreen.opacity(0.45), .clear],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: geo.size.width * 0.3, height: geo.size.height * 1.6)
                .rotationEffect(.degrees(18))
                .offset(x: position * geo.size.width * 1.3 + geo.size.width * 0.35, y: -geo.size.height * 0.3)
        }
        .clipShape(Capsule())
        .allowsHitTesting(false)
        .opacity(reduceMotion ? 0 : 1)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.3).delay(2.2).repeatForever(autoreverses: false)) { position = 1 }
        }
    }
}
