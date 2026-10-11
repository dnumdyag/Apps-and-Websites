import SwiftUI
import CoreText

/// Tab bar icons, each with a small animation when tapped. `taps` goes up by one on every tap.
struct TabIcon: View {
    let tab: AppTab
    let selected: Bool
    let taps: Int

    var body: some View {
        icon.offset(y: Self.baselineShift[tab] ?? 0)
    }

    @ViewBuilder private var icon: some View {
        switch tab {
        case .home: HomeIcon(taps: taps)
        case .journey: JourneyIcon(taps: taps)
        case .mia: LiquidOrbIcon(selected: selected, taps: taps)
        case .sessions: CigarIcon(selected: selected, taps: taps)
        case .community: CommunityIcon(selected: selected, taps: taps)
        }
    }

    /// Puts the bottom of every icon on one line, the base of the house (measured from the bar at
    /// 3x, 12 October 2026: the icons' lowest ink sat up to 2.7 pt apart).
    private static let baselineShift: [AppTab: CGFloat] = [
        .journey: 1.0 / 3,
        .mia: -1.0 / 3,
        .sessions: 5.0 / 3,
        .community: 7.0 / 3,
    ]

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

// MARK: - Sessions: a Robusto (Ed's pick, 11 Oct 2026). On tap it lifts as if raised to the lips,
// the ember glows with the draw, then it settles with a soft spring as the smoke curls up again.

private struct CigarIcon: View {
    let selected: Bool
    let taps: Int

    /// `.bar` draws it in the tab bar's own colour like the other icons (details as fine gaps, the band
    /// gold when selected, ash and smoke at half strength); `.natural` draws it in a cigar's colours.
    enum Palette { case bar, natural }
    static let palette: Palette = .bar

    private struct Motion {
        var lift: CGFloat = 0     // 0 at rest, 1 fully raised
        var ember: Double = 0
        var smoke: CGFloat = 1
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            GeometryReader { geo in
                let rect = CGRect(origin: .zero, size: geo.size)
                let unit = Grid(rect: rect).unit
                let pivot = Robusto.point(Robusto.pivot, in: rect)
                let tip = Robusto.point(Robusto.smokeStart, in: rect)
                let angle = -11 * m.lift
                // Where the tip has moved to, so the smoke rides with it but stays upright.
                let rad = Double(angle) * .pi / 180
                let v = CGPoint(x: tip.x - pivot.x, y: tip.y - pivot.y)
                let moved = CGPoint(x: pivot.x + v.x * cos(rad) - v.y * sin(rad),
                                    y: pivot.y + v.x * sin(rad) + v.y * cos(rad))
                ZStack {
                    cigar(in: rect, ember: m.ember)
                        .rotationEffect(.degrees(Double(angle)),
                                        anchor: UnitPoint(x: pivot.x / rect.width, y: pivot.y / rect.height))
                    smoke(progress: m.smoke, unit: unit)
                        .offset(x: moved.x - tip.x, y: moved.y - tip.y)
                }
                .offset(y: -1.1 * unit * m.lift)
            }
            .frame(width: 30, height: 26)
        } keyframes: { _ in
            // Raised to the lips, a moment there, then a soft spring back down.
            KeyframeTrack(\.lift) {
                CubicKeyframe(1, duration: 0.34)
                LinearKeyframe(1, duration: 0.08)
                SpringKeyframe(0, duration: 0.85, spring: .bouncy)
            }
            // The ember glows with the draw.
            KeyframeTrack(\.ember) {
                LinearKeyframe(0, duration: 0.15)
                CubicKeyframe(1, duration: 0.25)
                LinearKeyframe(1, duration: 0.2)
                CubicKeyframe(0, duration: 0.6)
            }
            // Then the smoke curls up again from the tip.
            KeyframeTrack(\.smoke) {
                MoveKeyframe(0)
                LinearKeyframe(0, duration: 0.5)
                CubicKeyframe(1, duration: 0.8)
            }
        }
    }

    @ViewBuilder
    private func cigar(in rect: CGRect, ember: Double) -> some View {
        switch Self.palette {
        case .bar:
            ZStack {
                Robusto.Part(kind: .body, cut: true).fill()
                Robusto.Part(kind: .band, cut: true).fill(selected ? Theme.goldDot : Color(hex: 0x0B1410))
                Robusto.Part(kind: .ash, cut: true).fill().opacity(0.5)
                Robusto.Part(kind: .ember, cut: true).fill(Theme.goldDot).opacity(ember)
            }
        case .natural:
            let across = Robusto.across(in: rect)
            ZStack {
                Robusto.Part(kind: .body, cut: false)
                    .fill(LinearGradient(stops: [.init(color: Color(hex: 0xB4794A), location: 0),
                                                 .init(color: Color(hex: 0x8C5631), location: 0.36),
                                                 .init(color: Color(hex: 0x4A2814), location: 1)],
                                         startPoint: across.0, endPoint: across.1))
                Robusto.Part(kind: .seams, cut: false).fill(Color(hex: 0x3A1F0E).opacity(0.55))
                Robusto.Part(kind: .band, cut: false)
                    .fill(LinearGradient(stops: [.init(color: Color(hex: 0xF5DC8C), location: 0),
                                                 .init(color: Color(hex: 0xD0A148), location: 0.5),
                                                 .init(color: Color(hex: 0x8D6421), location: 1)],
                                         startPoint: across.0, endPoint: across.1))
                Robusto.Part(kind: .bandLines, cut: false).fill(Color(hex: 0x7A5418))
                Robusto.Part(kind: .crest, cut: false).fill(Color(hex: 0x8C2318))
                Robusto.Part(kind: .ember, cut: false).fill(Color(hex: 0xB8391A))
                Robusto.Part(kind: .ash, cut: false)
                    .fill(LinearGradient(stops: [.init(color: Color(hex: 0xE6E2DB), location: 0),
                                                 .init(color: Color(hex: 0xBEB7AD), location: 0.5),
                                                 .init(color: Color(hex: 0x8E877D), location: 1)],
                                         startPoint: across.0, endPoint: across.1))
                Robusto.Part(kind: .ashRings, cut: false).fill(Color(hex: 0x7D766C))
                Robusto.Part(kind: .ember, cut: false).fill(Color(hex: 0xFF8A3C)).blur(radius: 0.6).opacity(ember)
            }
        }
    }

    @ViewBuilder
    private func smoke(progress: CGFloat, unit: CGFloat) -> some View {
        switch Self.palette {
        case .bar:
            RobustoSmoke(progress: progress)
                .stroke(style: StrokeStyle(lineWidth: 1.5 * unit, lineCap: .round))
                .opacity(0.5)
        case .natural:
            RobustoSmoke(progress: progress)
                .stroke(Color(hex: 0xA3ACA9), style: StrokeStyle(lineWidth: 1.1 * unit, lineCap: .round))
                .opacity(0.85)
        }
    }
}

/// A Robusto drawn as a real cigar, in its own coordinates (x from the head at 0 to the foot at L,
/// y across), lying on a diagonal in the 24 x 24 grid: rounded cap with its seam, two wrapper seams,
/// a band with a crest, an ember ring and a tip of flaky ash.
private enum Robusto {
    static let L: CGFloat = 20.4, D: CGFloat = 4.8
    static let r = D / 2
    static let ash: CGFloat = 3.2, gap: CGFloat = 0.6
    static let xt = L - ash - gap          // where the tobacco ends and the ember starts
    static let xa = xt + gap               // where the ash starts
    static let ra = r * 0.97
    static let hl = 0.6 * D                // length of the rounded cap
    static let bandW: CGFloat = 2.4
    static let bc = hl + 0.75 + bandW / 2  // centre of the band
    static let b0 = bc - bandW / 2, b1 = bc + bandW / 2
    static let bh = D * 1.1                // the band stands a little proud of the body
    static let pivot = CGPoint(x: 0.6 * D, y: 0)           // the mouth end, just behind the cap
    static let smokeStart = CGPoint(x: L - 0.9, y: -ra - 0.35)

    static func place(_ rect: CGRect) -> CGAffineTransform {
        let g = Grid(rect: rect)
        return CGAffineTransform(translationX: -L / 2, y: 0)
            .concatenating(CGAffineTransform(rotationAngle: -.pi / 6))
            .concatenating(CGAffineTransform(translationX: 11.4, y: 14.4))
            .concatenating(CGAffineTransform(scaleX: g.unit, y: g.unit))
            .concatenating(CGAffineTransform(translationX: rect.midX - 12 * g.unit, y: rect.midY - 12 * g.unit))
    }

    static func point(_ p: CGPoint, in rect: CGRect) -> CGPoint { p.applying(place(rect)) }

    /// Gradient end points across the cigar (top edge to bottom edge), as unit points of the frame.
    static func across(in rect: CGRect) -> (UnitPoint, UnitPoint) {
        let a = point(CGPoint(x: L / 2, y: -r), in: rect), b = point(CGPoint(x: L / 2, y: r), in: rect)
        return (UnitPoint(x: a.x / rect.width, y: a.y / rect.height), UnitPoint(x: b.x / rect.width, y: b.y / rect.height))
    }

    static var bodyPath: Path {
        var p = Path()
        p.move(to: CGPoint(x: hl, y: -r))
        p.addCurve(to: CGPoint(x: 0, y: 0), control1: CGPoint(x: hl * 0.42, y: -r), control2: CGPoint(x: 0, y: -r * 0.68))
        p.addCurve(to: CGPoint(x: hl, y: r), control1: CGPoint(x: 0, y: r * 0.68), control2: CGPoint(x: hl * 0.42, y: r))
        p.addLine(to: CGPoint(x: xt, y: r))
        p.addLine(to: CGPoint(x: xt, y: -r))
        p.closeSubpath()
        return p
    }

    /// The cap's seam and the wrapper leaf's two spiral seams, as centre lines.
    static var seamLines: Path {
        var p = Path()
        p.move(to: CGPoint(x: hl * 1.02, y: -r))
        p.addQuadCurve(to: CGPoint(x: hl * 1.02, y: r), control: CGPoint(x: hl * 0.6, y: 0))
        for i in 0..<2 {
            let x = b1 + 1.6 + (CGFloat(i) + 0.5) * (xt - b1 - 2.8) / 2
            p.move(to: CGPoint(x: x, y: -r))
            p.addQuadCurve(to: CGPoint(x: x + D * 0.55, y: r), control: CGPoint(x: x + D * 0.2, y: 0))
        }
        return p
    }

    static var ashPath: Path {
        var p = Path()
        p.move(to: CGPoint(x: xa, y: -ra))
        p.addLine(to: CGPoint(x: L - 0.7, y: -ra))
        p.addQuadCurve(to: CGPoint(x: L - 0.25, y: -ra * 0.45), control: CGPoint(x: L - 0.1, y: -ra))
        p.addQuadCurve(to: CGPoint(x: L - 0.1, y: ra * 0.25), control: CGPoint(x: L + 0.15, y: -ra * 0.1))
        p.addQuadCurve(to: CGPoint(x: L - 0.6, y: ra), control: CGPoint(x: L + 0.05, y: ra * 0.75))
        p.addLine(to: CGPoint(x: xa, y: ra))
        p.closeSubpath()
        return p
    }

    static var ashRingLines: Path {
        var p = Path()
        for f: CGFloat in [0.38, 0.7] {
            let x = xa + ash * f
            p.move(to: CGPoint(x: x, y: -ra))
            p.addQuadCurve(to: CGPoint(x: x, y: ra), control: CGPoint(x: x - 0.35, y: 0))
        }
        return p
    }

    static func line(_ p: Path, _ width: CGFloat) -> Path { p.strokedPath(StrokeStyle(lineWidth: width, lineCap: .butt)) }

    struct Part: Shape {
        enum Kind { case body, seams, band, bandLines, crest, ember, ash, ashRings }
        let kind: Kind
        /// true: the bar style, with the details cut out as fine gaps
        let cut: Bool

        func path(in rect: CGRect) -> Path {
            let shape: Path
            switch kind {
            case .body:
                if cut {
                    let gaps = Path(CGRect(x: b0 - 0.5, y: -D, width: 0.5, height: 2 * D))
                        .union(Path(CGRect(x: b1, y: -D, width: 0.5, height: 2 * D)))
                        .union(line(seamLines, 0.42))
                    shape = bodyPath.subtracting(gaps)
                } else {
                    shape = bodyPath
                }
            case .seams:
                shape = line(seamLines, 0.3).intersection(bodyPath)
            case .band:
                let band = Path(roundedRect: CGRect(x: b0, y: -bh / 2, width: bandW, height: bh), cornerRadius: 0.3)
                shape = cut ? band.subtracting(Path(ellipseIn: CGRect(x: bc - bandW * 0.26, y: -bh * 0.2, width: bandW * 0.52, height: bh * 0.4)))
                            : band
            case .bandLines:
                var p = Path()
                p.move(to: CGPoint(x: b0, y: -bh / 2 + 0.42)); p.addLine(to: CGPoint(x: b1, y: -bh / 2 + 0.42))
                p.move(to: CGPoint(x: b0, y: bh / 2 - 0.42)); p.addLine(to: CGPoint(x: b1, y: bh / 2 - 0.42))
                shape = line(p, 0.2)
            case .crest:
                shape = Path(ellipseIn: CGRect(x: bc - bandW * 0.3, y: -bh * 0.25, width: bandW * 0.6, height: bh * 0.5))
            case .ember:
                shape = Path(CGRect(x: xt - 0.05, y: -r, width: gap + 0.1, height: 2 * r))
            case .ash:
                shape = cut ? ashPath.subtracting(line(ashRingLines, 0.38)) : ashPath
            case .ashRings:
                shape = line(ashRingLines, 0.28).intersection(ashPath)
            }
            return shape.applying(Robusto.place(rect))
        }
    }
}

/// A curl of smoke rising from the lit end. `progress` is how much of it is drawn.
private struct RobustoSmoke: Shape {
    var progress: CGFloat

    func path(in rect: CGRect) -> Path {
        let u = Grid(rect: rect).unit
        let s = Robusto.point(Robusto.smokeStart, in: rect)
        let k: CGFloat = 6 / 7
        var path = Path()
        path.move(to: s)
        path.addCurve(to: CGPoint(x: s.x - 0.3 * u, y: s.y - 7 * k * u),
                      control1: CGPoint(x: s.x - 2.1 * u, y: s.y - 2.3 * k * u),
                      control2: CGPoint(x: s.x + 2 * u, y: s.y - 4.5 * k * u))
        return progress >= 1 ? path : path.trimmedPath(from: 0, to: max(0, progress))
    }
}

// MARK: - Mia: the Liquid orb (Ed's pick, 11 Oct 2026). An M on an orb; on tap light swirls
// inside the orb like liquid, the M melts into it, then rises again. Selected: green orb, gold M.
// Not selected: a dark orb with the M cut out, so gold stays with the selected tab.

private struct LiquidOrbIcon: View {
    let selected: Bool
    let taps: Int

    private static let size: CGFloat = 23
    private static let blobColors = [Theme.goldDot, Theme.onGreenMuted, Theme.goldOnGreen]
    private static let blobSizes: [CGFloat] = [0.39, 0.32, 0.25]

    var body: some View {
        KeyframeAnimator(initialValue: CGFloat(0), trigger: taps) { p in
            let b = envelope(p, 0.25, 0.7)
            let wobble = 1 + 0.045 * sin(p * .pi * 6) * b
            ZStack {
                Circle().fill(selected ? Theme.green : Color(hex: 0x0B1410))
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        let a = p * .pi * 2 * (1.2 + CGFloat(i) * 0.45) + CGFloat(i) * 2.1
                        Circle()
                            .fill(Self.blobColors[i])
                            .frame(width: Self.size * Self.blobSizes[i], height: Self.size * Self.blobSizes[i])
                            .offset(x: Self.size * 0.216 * cos(a), y: Self.size * 0.216 * sin(a * 1.3))
                    }
                }
                .blur(radius: 1.8)
                .opacity(b * 0.95)
                // Clip to the whole orb, not just the swirls' own bounds.
                .frame(width: Self.size, height: Self.size)
                .clipShape(Circle())
                monogram
                    .opacity(1 - b)
                    .scaleEffect(1 - 0.25 * b)
            }
            .compositingGroup()
            .frame(width: Self.size, height: Self.size)
            .scaleEffect(x: wobble, y: 2 - wobble)
            .frame(width: 30, height: 26)
        } keyframes: { _ in
            KeyframeTrack {
                MoveKeyframe(0)
                LinearKeyframe(1, duration: 1.6)
            }
        }
    }

    @ViewBuilder private var monogram: some View {
        let m = MonogramShape(capHeight: 10.6)
            .frame(width: Self.size, height: Self.size)
        if selected {
            m.foregroundStyle(Theme.goldOnGreen)
        } else {
            m.foregroundStyle(.white).blendMode(.destinationOut)
        }
    }
}

/// The letter M drawn from Cormorant Garamond Bold's own outline and centred on its ink, not on
/// its line box (a Text view centres the line box, which carries invisible space above and below
/// the letter, so the M drifts). Measured: the M's visual weight sits 2.8% of its width right of
/// its outline centre, so it is nudged left by 40% of that to sit centred to the eye.
private struct MonogramShape: Shape {
    var capHeight: CGFloat

    private static let outline: CGPath? = {
        let font = CTFontCreateWithName("CormorantGaramond-Bold" as CFString, 100, nil)
        var character: UniChar = 77 // "M"
        var glyph: CGGlyph = 0
        guard CTFontGetGlyphsForCharacters(font, &character, &glyph, 1) else { return nil }
        return CTFontCreatePathForGlyph(font, glyph, nil)
    }()

    func path(in rect: CGRect) -> Path {
        guard let outline = Self.outline else { return Path() }
        let box = outline.boundingBoxOfPath
        let scale = capHeight / box.height
        let nudge = -0.4 * 0.028 * box.width * scale
        // Core Text draws upward from the baseline: centre the ink box, flip it, scale it.
        var transform = CGAffineTransform(translationX: rect.midX + nudge, y: rect.midY)
            .scaledBy(x: scale, y: -scale)
            .translatedBy(x: -box.midX, y: -box.midY)
        return Path(outline.copy(using: &transform) ?? outline)
    }
}

/// Rises 0 to 1 over [0, a], holds, and falls back over [b, 1], eased in and out
/// (the same curve as the options page).
private func envelope(_ p: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat {
    func easeInOut(_ t: CGFloat) -> CGFloat { t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2 }
    if p < a { return easeInOut(p / a) }
    if p > b { return easeInOut(1 - (p - b) / (1 - b)) }
    return 1
}
