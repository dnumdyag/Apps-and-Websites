import SwiftUI

// MARK: - Card

struct MiaCard: ViewModifier {
    var padding: CGFloat = 24
    var fill: AnyShapeStyle = AnyShapeStyle(Theme.cardFill)

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Theme.border.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
    }
}

extension View {
    func miaCard(padding: CGFloat = 24) -> some View {
        modifier(MiaCard(padding: padding))
    }

    func miaCard<S: ShapeStyle>(padding: CGFloat = 24, fill: S) -> some View {
        modifier(MiaCard(padding: padding, fill: AnyShapeStyle(fill)))
    }

    /// Full screen gradient background used behind every screen.
    func miaBackground() -> some View {
        background(Theme.background.ignoresSafeArea())
    }
}

// MARK: - Buttons

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Theme.bgTop)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.goldFill, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .light))
            .foregroundStyle(Theme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.chip.opacity(0.5), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.border.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct ChipButtonStyle: ButtonStyle {
    var selected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .light))
            .foregroundStyle(selected ? Theme.bgTop : Theme.textSoft)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(selected ? AnyShapeStyle(Theme.goldFill) : AnyShapeStyle(Theme.chip.opacity(0.5)))
            )
            .overlay(Capsule().stroke(Theme.border.opacity(selected ? 0 : 0.35), lineWidth: 1))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// MARK: - Text helpers

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.text)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }
}

struct SectionLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .light))
            .tracking(1.8)
            .foregroundStyle(Theme.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct IconBubble: View {
    let systemName: String
    var tint: Color = Theme.gold
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.4, weight: .light))
            .foregroundStyle(tint.opacity(0.9))
            .frame(width: size, height: size)
            .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: size * 0.35, style: .continuous))
    }
}

struct Pill: View {
    let text: String
    var tint: Color = Theme.gold

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(tint.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.25), lineWidth: 1))
    }
}

struct MiaAvatar: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.gold.opacity(0.12))
                .blur(radius: 10)
            Circle()
                .fill(LinearGradient(colors: [Theme.border.opacity(0.7), Theme.chip.opacity(0.8)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Circle().stroke(Theme.gold.opacity(0.3), lineWidth: 1))
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.4, weight: .light))
                .foregroundStyle(Theme.gold)
        }
        .frame(width: size, height: size)
    }
}

/// Simple wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(widest, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
