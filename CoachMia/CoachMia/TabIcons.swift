import SwiftUI

/// Tab bar icons, each with a small animation when tapped. `taps` goes up by one on every tap.
struct TabIcon: View {
    let tab: AppTab
    let selected: Bool
    let taps: Int

    var body: some View {
        switch tab {
        case .home: HomeIcon(taps: taps)
        case .journey: JourneyIcon(taps: taps)
        case .mia:
            #if DEBUG
            // `-miaPreview` shows the candidate monogram so Ed can judge it in the bar.
            if ProcessInfo.processInfo.arguments.contains("-miaPreview") {
                MiaMonogram(taps: taps)
            } else {
                symbol("bubble.left.fill")
            }
            #else
            symbol("bubble.left.fill")
            #endif
        case .sessions: CigarIcon(selected: selected, taps: taps)
        case .community: CommunityIcon(selected: selected, taps: taps)
        }
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 21, weight: .medium))
            .frame(width: 30, height: 26)
    }
}

/// Maps points on a 24 x 24 design grid (the SF Symbols grid) into a rect.
private struct Grid {
    let rect: CGRect
    var unit: CGFloat { min(rect.width, rect.height) / 24 }

    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.midX + (x - 12) * unit, y: rect.midY + (y - 12) * unit)
    }

    func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(origin: p(x, y), size: CGSize(width: w * unit, height: h * unit))
    }
}

// MARK: - Home: Apple's house; on tap smoke rises from the chimney, the door opens a crack of
// gold light, and it squashes softly with a gentle bounce

private struct HomeIcon: View {
    let taps: Int

    // Where the chimney and door sit on Apple's house.fill, as fractions of the symbol's frame
    // (measured from the symbol itself).
    private static let chimney = CGPoint(x: 0.76, y: 0.16)
    private static let door = CGRect(x: 0.406, y: 0.59, width: 0.182, height: 0.26)

    private struct Motion {
        var squashX: CGFloat = 1
        var squashY: CGFloat = 1
        var lift: CGFloat = 0
        var crack: CGFloat = 0
        var glow: Double = 0
        var smoke: CGFloat = 0
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            Image(systemName: "house.fill")
                .font(.system(size: 21, weight: .medium))
                .overlay {
                    GeometryReader { geo in
                        let size = geo.size
                        let door = CGRect(x: Self.door.minX * size.width, y: Self.door.minY * size.height,
                                          width: Self.door.width * size.width, height: Self.door.height * size.height)
                        // Warm light through the gap on the latch side of the door.
                        RoundedRectangle(cornerRadius: 0.8)
                            .fill(Theme.goldDot)
                            .frame(width: door.width * m.crack, height: door.height)
                            .position(x: door.maxX - door.width * m.crack / 2, y: door.midY)
                            .opacity(m.glow)
                        ChimneySmoke(progress: m.smoke)
                            .position(x: Self.chimney.x * size.width, y: Self.chimney.y * size.height)
                    }
                }
                .frame(width: 30, height: 26)
                .scaleEffect(x: m.squashX, y: m.squashY, anchor: .bottom)
                .offset(y: m.lift)
        } keyframes: { _ in
            // Squash as it is pressed down, then a gentle bounce back up.
            KeyframeTrack(\.squashY) {
                CubicKeyframe(0.92, duration: 0.09)
                SpringKeyframe(1, duration: 0.45, spring: .bouncy)
            }
            KeyframeTrack(\.squashX) {
                CubicKeyframe(1.05, duration: 0.09)
                SpringKeyframe(1, duration: 0.45, spring: .bouncy)
            }
            KeyframeTrack(\.lift) {
                CubicKeyframe(0, duration: 0.09)
                CubicKeyframe(-2, duration: 0.14)
                SpringKeyframe(0, duration: 0.32, spring: .bouncy)
            }
            KeyframeTrack(\.crack) {
                CubicKeyframe(0.55, duration: 0.2)
                LinearKeyframe(0.55, duration: 0.35)
                CubicKeyframe(0, duration: 0.35)
            }
            KeyframeTrack(\.glow) {
                CubicKeyframe(1, duration: 0.15)
                LinearKeyframe(1, duration: 0.45)
                CubicKeyframe(0, duration: 0.4)
            }
            KeyframeTrack(\.smoke) {
                MoveKeyframe(0)
                LinearKeyframe(1, duration: 1.3)
            }
        }
    }
}

/// Three soft puffs that rise from the chimney one after another, drift and fade.
/// `progress` runs 0 to 1 over the whole effect.
private struct ChimneySmoke: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let t = min(max((progress - CGFloat(i) * 0.18) / 0.62, 0), 1)
                Circle()
                    .frame(width: 2.4 + t * 3, height: 2.4 + t * 3)
                    .offset(x: t * 3 + sin(t * .pi) * 1.2, y: -t * 10)
                    .opacity(t > 0 ? Double(min(t * 5, 1) * (1 - t)) * 0.55 : 0)
            }
        }
        .frame(width: 1, height: 1)
    }
}

// MARK: - Journey: the path redraws itself with a dot running ahead, then flexes very slightly

private struct JourneyIcon: View {
    let taps: Int

    private struct Motion {
        var draw: CGFloat = 1
        var dot: CGFloat = 0
        var dotOpacity: Double = 0
        var flex: CGFloat = 0
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            ZStack {
                JourneyRings()
                    .stroke(style: StrokeStyle(lineWidth: 2.1))
                JourneyCurve(flex: m.flex, progress: m.draw)
                    .stroke(style: StrokeStyle(lineWidth: 2.1, lineCap: .round))
                JourneyDot(t: m.dot, flex: m.flex)
                    .opacity(m.dotOpacity)
            }
            .frame(width: 26, height: 26)
        } keyframes: { _ in
            // MoveKeyframe jumps without carrying speed into the next keyframe; a fast
            // LinearKeyframe here made the cubic curve dip below zero and hide the line.
            // A short pause first, so the screen change doesn't swallow the start of the line.
            KeyframeTrack(\.draw) {
                MoveKeyframe(0)
                LinearKeyframe(0, duration: 0.15)
                CubicKeyframe(1, duration: 0.6)
            }
            KeyframeTrack(\.dot) {
                MoveKeyframe(0)
                LinearKeyframe(0, duration: 0.15)
                CubicKeyframe(1, duration: 0.6)
            }
            KeyframeTrack(\.dotOpacity) {
                MoveKeyframe(1)
                LinearKeyframe(1, duration: 0.75)
                CubicKeyframe(0, duration: 0.25)
            }
            KeyframeTrack(\.flex) {
                LinearKeyframe(0, duration: 0.72)
                CubicKeyframe(1.2, duration: 0.14)
                SpringKeyframe(0, duration: 0.45, spring: .bouncy)
            }
        }
    }
}

/// The start and end points of the journey.
private struct JourneyRings: Shape {
    func path(in rect: CGRect) -> Path {
        let g = Grid(rect: rect)
        let r = 2.5 * g.unit
        var path = Path()
        for center in [g.p(6, 5.6), g.p(18, 18.4)] {
            path.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
        }
        return path
    }
}

/// The winding path between the two points. `flex` bends it slightly; `progress` (0 to 1)
/// is how much of it is drawn.
private struct JourneyCurve: Shape {
    var flex: CGFloat
    var progress: CGFloat = 1

    func path(in rect: CGRect) -> Path {
        let g = Grid(rect: rect)
        var path = Path()
        path.move(to: g.p(6, 8.3))
        path.addCurve(to: g.p(18, 15.7), control1: g.p(6 + flex, 15), control2: g.p(18 - flex, 9))
        return progress >= 1 ? path : path.trimmedPath(from: 0, to: max(0, progress))
    }
}

/// A small dot at position `t` (0 to 1) along the path.
private struct JourneyDot: Shape {
    var t: CGFloat
    var flex: CGFloat

    func path(in rect: CGRect) -> Path {
        let curve = JourneyCurve(flex: flex).path(in: rect)
        guard let point = curve.trimmedPath(from: 0, to: max(0.001, t)).currentPoint else { return Path() }
        let r = 1.9 * Grid(rect: rect).unit
        return Path(ellipseIn: CGRect(x: point.x - r, y: point.y - r, width: 2 * r, height: 2 * r))
    }
}

// MARK: - Community: the two figures hop one after the other; one turns gold when selected

private struct CommunityIcon: View {
    let selected: Bool
    let taps: Int

    var body: some View {
        Image(systemName: "person.2.fill")
            .font(.system(size: 21, weight: .medium))
            .symbolRenderingMode(.palette)
            .foregroundStyle(selected ? Theme.green : Color(hex: 0x0B1410),
                             selected ? Theme.goldDot : Color(hex: 0x0B1410))
            .symbolEffect(.bounce.up.byLayer, options: .speed(1.1), value: taps)
            .frame(width: 30, height: 26)
    }
}

// MARK: - Sessions: a cigar; on tap the ember glows gold and the smoke curls up again

private struct CigarIcon: View {
    let selected: Bool
    let taps: Int

    private struct Motion {
        var ember: Double = 0
        var smoke: CGFloat = 1
        var sway: CGFloat = 0
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            ZStack {
                CigarShape(part: .body)
                CigarShape(part: .band)
                    .fill(selected ? Theme.goldDot : Color(hex: 0x0B1410))
                CigarShape(part: .ember)
                    .fill(Color(hex: 0x0B1410).opacity(0.45))
                CigarShape(part: .ember)
                    .fill(Theme.goldDot)
                    .opacity(m.ember)
                CigarSmoke(progress: m.smoke, sway: m.sway)
                    .stroke(style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                    .opacity(0.6)
            }
            .frame(width: 30, height: 26)
        } keyframes: { _ in
            // The ember glows as if drawn on.
            KeyframeTrack(\.ember) {
                CubicKeyframe(1, duration: 0.2)
                LinearKeyframe(1, duration: 0.3)
                CubicKeyframe(0, duration: 0.5)
            }
            // The smoke curl draws itself up again from the tip, swaying slightly.
            KeyframeTrack(\.smoke) {
                MoveKeyframe(0)
                LinearKeyframe(0, duration: 0.1)
                CubicKeyframe(1, duration: 0.7)
            }
            KeyframeTrack(\.sway) {
                LinearKeyframe(0, duration: 0.3)
                CubicKeyframe(1, duration: 0.3)
                SpringKeyframe(0, duration: 0.5, spring: .smooth)
            }
        }
    }
}

/// The cigar lies on a diagonal: mouth end bottom left, lit end top right, with a gold band
/// near the mouth end (gold when the tab is selected).
private struct CigarShape: Shape {
    enum Part { case body, band, ember }
    let part: Part

    /// Turns the cigar's own coordinates (lying flat, x along its length) into the 24 x 24 grid.
    static func place(_ rect: CGRect) -> CGAffineTransform {
        let g = Grid(rect: rect)
        return CGAffineTransform(translationX: -9.4, y: 0)
            .concatenating(CGAffineTransform(rotationAngle: -.pi / 6))
            .concatenating(CGAffineTransform(translationX: 10.4, y: 14.4))
            .concatenating(CGAffineTransform(scaleX: g.unit, y: g.unit))
            .concatenating(CGAffineTransform(translationX: rect.midX - 12 * g.unit, y: rect.midY - 12 * g.unit))
    }

    func path(in rect: CGRect) -> Path {
        let shape: Path
        switch part {
        case .body:
            // The body, minus a slot where the band sits.
            shape = Path(roundedRect: CGRect(x: 0, y: -2.7, width: 16.4, height: 5.4), cornerRadius: 2.7)
                .subtracting(Path(CGRect(x: 3.6, y: -3.4, width: 2.8, height: 6.8)))
        case .band:
            shape = Path(roundedRect: CGRect(x: 4, y: -2.9, width: 2, height: 5.8), cornerRadius: 0.5)
        case .ember:
            shape = Path(roundedRect: CGRect(x: 16.9, y: -2.7, width: 2, height: 5.4),
                         cornerSize: CGSize(width: 1, height: 1.8))
        }
        return shape.applying(Self.place(rect))
    }
}

/// A thin curl of smoke rising from the lit end. `progress` is how much of it is drawn.
private struct CigarSmoke: Shape {
    var progress: CGFloat
    var sway: CGFloat

    func path(in rect: CGRect) -> Path {
        let g = Grid(rect: rect)
        let tip = CGPoint(x: 18.9, y: 0).applying(CigarShape.place(rect))
        let u = g.unit
        var path = Path()
        path.move(to: CGPoint(x: tip.x + 0.6 * u, y: tip.y - 2.6 * u))
        path.addCurve(to: CGPoint(x: tip.x + (1.6 + sway) * u, y: tip.y - 9.5 * u),
                      control1: CGPoint(x: tip.x - 1.8 * u, y: tip.y - 5 * u),
                      control2: CGPoint(x: tip.x + (3.6 + sway) * u, y: tip.y - 6 * u))
        return progress >= 1 ? path : path.trimmedPath(from: 0, to: max(0, progress))
    }
}

// MARK: - Mia (candidate, shown only with -miaPreview): her initial in a filled circle, like a
// monogram seal; on tap it presses down like a stamp and a gold glint crosses it

private struct MiaMonogram: View {
    let taps: Int

    private struct Motion {
        var press: CGFloat = 1
        var glint: CGFloat = -1
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            ZStack {
                Circle()
                    .frame(width: 23, height: 23)
                    .overlay {
                        Text("M")
                            .font(Theme.serif(17, .bold))
                            .foregroundStyle(.white)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                LinearGradient(colors: [.clear, Theme.goldDot.opacity(0.9), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(width: 8, height: 30)
                    .rotationEffect(.degrees(20))
                    .offset(x: m.glint * 16)
                    .mask(Circle().frame(width: 23, height: 23))
            }
            .frame(width: 30, height: 26)
            .scaleEffect(m.press)
        } keyframes: { _ in
            KeyframeTrack(\.press) {
                CubicKeyframe(0.88, duration: 0.1)
                SpringKeyframe(1, duration: 0.45, spring: .bouncy)
            }
            KeyframeTrack(\.glint) {
                MoveKeyframe(-1)
                LinearKeyframe(-1, duration: 0.1)
                CubicKeyframe(1, duration: 0.5)
            }
        }
    }
}
