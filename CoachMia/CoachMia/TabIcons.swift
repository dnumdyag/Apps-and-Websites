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
        case .mia: symbol("bubble.left.fill")
        case .sessions: symbol("play.rectangle.fill")
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

// MARK: - Home: squash, gentle bounce, the door opens a crack and the window glows gold

private struct HomeIcon: View {
    let taps: Int

    private struct Motion {
        var squashX: CGFloat = 1
        var squashY: CGFloat = 1
        var lift: CGFloat = 0
        var crack: CGFloat = 0
        var glow: Double = 0
    }

    var body: some View {
        KeyframeAnimator(initialValue: Motion(), trigger: taps) { m in
            ZStack {
                HouseShape()
                HouseLights(crack: m.crack)
                    .fill(Theme.goldDot)
                    .opacity(m.glow)
            }
            .frame(width: 26, height: 26)
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
            // The door opens a crack, warm light shows in the doorway and the window, then it closes.
            KeyframeTrack(\.crack) {
                CubicKeyframe(0.55, duration: 0.2)
                LinearKeyframe(0.55, duration: 0.25)
                CubicKeyframe(0, duration: 0.3)
            }
            KeyframeTrack(\.glow) {
                CubicKeyframe(1, duration: 0.15)
                LinearKeyframe(1, duration: 0.35)
                CubicKeyframe(0, duration: 0.4)
            }
        }
    }
}

/// A filled house with overhanging eaves, a doorway and a small window, drawn so the door and
/// window can light up.
private struct HouseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let g = Grid(rect: rect)
        // Small radii at the eaves: their corners sit close together, and larger ones overlap.
        let outline = roundedPolygon([
            (g.p(12, 2.2), 1.2), (g.p(22.4, 11.2), 0.5), (g.p(19.4, 11.2), 0.4), (g.p(19.4, 21.4), 1.2),
            (g.p(4.6, 21.4), 1.2), (g.p(4.6, 11.2), 0.4), (g.p(1.6, 11.2), 0.5),
        ].map { ($0.0, $0.1 * g.unit) })
        let door = Path(roundedRect: g.box(10, 14.6, 4, 9), cornerRadius: 1 * g.unit)
        let window = Path(roundedRect: g.box(15.3, 12.9, 2.4, 2.4), cornerRadius: 0.5 * g.unit)
        return outline.subtracting(door).subtracting(window)
    }
}

/// The light in the window and in the doorway. `crack` (0 to 1) is how far the door has opened.
private struct HouseLights: Shape {
    var crack: CGFloat

    func path(in rect: CGRect) -> Path {
        let g = Grid(rect: rect)
        var path = Path(roundedRect: g.box(15.3, 12.9, 2.4, 2.4), cornerRadius: 0.5 * g.unit)
        // Light spills through the gap on the latch side of the door.
        let gap = 4 * crack
        path.addRect(g.box(14 - gap, 14.6, gap, 6.8))
        return path
    }
}

/// A closed polygon with each corner rounded by its own radius.
private func roundedPolygon(_ corners: [(CGPoint, CGFloat)]) -> Path {
    var path = Path()
    let first = corners[0].0, last = corners[corners.count - 1].0
    path.move(to: CGPoint(x: (last.x + first.x) / 2, y: (last.y + first.y) / 2))
    for i in corners.indices {
        let (point, radius) = corners[i]
        path.addArc(tangent1End: point, tangent2End: corners[(i + 1) % corners.count].0, radius: radius)
    }
    path.closeSubpath()
    return path
}

// MARK: - Journey: the path redraws itself fast with a dot running ahead, then flexes very slightly

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
            KeyframeTrack(\.draw) {
                MoveKeyframe(0)
                CubicKeyframe(1, duration: 0.24)
            }
            KeyframeTrack(\.dot) {
                MoveKeyframe(0)
                CubicKeyframe(1, duration: 0.24)
            }
            KeyframeTrack(\.dotOpacity) {
                MoveKeyframe(1)
                LinearKeyframe(1, duration: 0.24)
                CubicKeyframe(0, duration: 0.15)
            }
            KeyframeTrack(\.flex) {
                LinearKeyframe(0, duration: 0.22)
                CubicKeyframe(1.2, duration: 0.12)
                SpringKeyframe(0, duration: 0.4, spring: .bouncy)
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
