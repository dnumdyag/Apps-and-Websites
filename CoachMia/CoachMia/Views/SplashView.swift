import SwiftUI

/// The opening, about five seconds before Mia's interview (option 1 on the "Coach Mia Splash
/// Screens" page, as Ed asked on 12 October 2026). Four orbs of liquid light drift in, pull toward
/// each other and run together where they touch; the gold one whips round and slows; they settle
/// into a slow ring round the M. Skip moves straight on.
struct SplashView: View {
    var onFinish: () -> Void

    @State private var start = Date.now
    @State private var finished = false

    /// Seconds before the interview begins.
    static let length = 5.4

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: nil, paused: finished)) { context in
                let t = context.date.timeIntervalSince(start)
                GeometryReader { geo in
                    ZStack {
                        OrbField(t: t, size: geo.size)
                        titles(t: t, size: geo.size)
                    }
                }
            }
            .background(background)
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button("Skip", action: finish)
                        .font(Theme.sans(13, .semibold))
                        .foregroundStyle(Theme.onGreenMuted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08), in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 0.5))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .task {
            try? await Task.sleep(for: .seconds(Self.length))
            finish()
        }
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        onFinish()
    }

    private var background: some View {
        RadialGradient(colors: [Color(hex: 0x1A6550), Color(hex: 0x0E4234), Color(hex: 0x05201A)],
                       center: UnitPoint(x: 0.5, y: 0.42), startRadius: 0, endRadius: 560)
    }

    /// The M rises in the middle of the ring, then the name and the line beneath it.
    private func titles(t: Double, size: CGSize) -> some View {
        let m = smoothstep(3.4, 4.4, t)
        let name = smoothstep(3.8, 4.7, t)
        let line = smoothstep(4.1, 4.9, t)
        let box = size.width * 0.3
        return ZStack {
            MonogramShape(capHeight: size.width * 0.15)
                .fill(Theme.metalGold)
                .frame(width: box, height: box)
                .scaleEffect(0.88 + 0.12 * m)
                .blur(radius: (1 - m) * 6)
                .opacity(m)
                .position(x: size.width / 2, y: size.height * OrbField.centreY + (1 - m) * 12)
            Text("Coach Mia")
                .font(Theme.script(size.width * 0.17))
                .foregroundStyle(Theme.metalGold)
                .opacity(name)
                .position(x: size.width / 2, y: size.height * 0.665 + (1 - name) * 10)
            Text("CONSCIOUS LOVE · DATING · SELF-AWARENESS")
                .font(Theme.sans(10, .semibold))
                .tracking(2.2)
                .foregroundStyle(Theme.onGreenMuted)
                .opacity(line)
                .position(x: size.width / 2, y: size.height * 0.735)
        }
    }
}

/// The orbs: liquid light that runs together where orbs touch. Each circles a shared centre while
/// the circles tighten into a ring; orbs that pass close pull together and swell; the gold one
/// whips round at 1.5 s (540 degrees, slowing as it goes) and stretches with the speed.
private struct OrbField: View {
    let t: Double
    let size: CGSize

    /// The ring's centre, as a fraction of the screen's height.
    static let centreY: CGFloat = 0.44

    private struct Orb {
        /// Centre to edge, lit from the upper left.
        let colors: [Color]
        /// Sizes and distances in hundredths of the screen's width; angles in radians.
        let diameter: Double
        let r0: Double, r1: Double, a0: Double, w: Double
    }

    private static let orbs: [Orb] = [
        Orb(colors: [Color(hex: 0xFFF1C6), Color(hex: 0xE9C778), Color(hex: 0xB8862F)], diameter: 32, r0: 30, r1: 33, a0: -0.6, w: 0.8),
        Orb(colors: [Color(hex: 0x6FD3A8), Color(hex: 0x23805F), Color(hex: 0x0C3D2E)], diameter: 36, r0: 27, r1: 33, a0: 1.6, w: -0.55),
        Orb(colors: [Color(hex: 0xFFF8E6), Color(hex: 0xF0DDA6), Color(hex: 0xC9A55B)], diameter: 26, r0: 34, r1: 33, a0: 3.3, w: 1.0),
        Orb(colors: [Color(hex: 0xF4FBF7), Color(hex: 0xC9E6D8), Color(hex: 0x7FB59C)], diameter: 22, r0: 22, r1: 33, a0: 4.6, w: 0.35),
    ]

    private struct Pose {
        var x: CGFloat, y: CGFloat, radius: CGFloat
        /// Direction of travel round the centre, and how far it is drawn out along it.
        var angle: Double, stretch: CGFloat
    }

    var body: some View {
        let poses = poses()
        ZStack {
            // A soft glow of the same light behind the liquid.
            colour(poses)
                .blur(radius: size.width * 0.08)
                .opacity(0.45)
            ZStack {
                colour(poses)
                    .blur(radius: size.width * 0.02)
                edgeShade(poses)
                highlights(poses)
            }
            .mask(liquid(poses).blur(radius: 0.6))
        }
        .opacity(smoothstep(0, 0.8, t))
    }

    private func poses() -> [Pose] {
        let unit = size.width / 100
        let gather = smoothstep(0.9, 3.8, t)
        let grow = smoothstep(0, 1.2, t)
        let spinStart = 1.5, turn = 3 * Double.pi, settle = 0.3
        let spin = t < spinStart ? 0 : turn * (1 - exp(-(t - spinStart) / settle))
        let spinSpeed = t < spinStart ? 0 : turn / settle * exp(-(t - spinStart) / settle)

        var points: [(x: Double, y: Double, swell: Double, angle: Double, r: Double)] = Self.orbs.enumerated().map { i, orb in
            // Free orbits at first; as they gather, each eases onto an even ring that turns slowly.
            let free = orb.a0 + orb.w * t + (i == 0 ? spin : 0)
            let ring = 0.5 * t + Double(i) * .pi / 2 + 0.4
            var gap = (ring - free).truncatingRemainder(dividingBy: 2 * .pi)
            if gap > .pi { gap -= 2 * .pi }
            if gap < -.pi { gap += 2 * .pi }
            let angle = free + gather * gap
            let r = orb.r0 * (1 - gather) + orb.r1 * gather
            return (r * cos(angle), r * sin(angle) * 0.8, 1, angle, r)
        }
        // Orbs that pass close pull together and swell, until they settle into the ring.
        for i in points.indices {
            for j in points.indices where j > i {
                let dx = points[j].x - points[i].x, dy = points[j].y - points[i].y
                let d = max(hypot(dx, dy), 0.001)
                let pull = max(0, 24 - d) * 0.12 * (1 - gather)
                points[i].x += dx / d * pull
                points[i].y += dy / d * pull
                points[j].x -= dx / d * pull
                points[j].y -= dy / d * pull
                let swell = 0.18 * max(0, 1 - d / 28) * (1 - gather)
                points[i].swell += swell
                points[j].swell += swell
            }
        }
        return points.enumerated().map { i, p in
            let breathe = 1 + 0.03 * sin(2.1 * t + Double(i))
            let radius = Self.orbs[i].diameter / 2 * p.swell * breathe * (0.35 + 0.65 * grow)
            let speed = i == 0 ? spinSpeed * p.r : 0
            return Pose(x: size.width / 2 + CGFloat(p.x) * unit,
                        y: size.height * Self.centreY + CGFloat(p.y) * unit,
                        radius: CGFloat(radius) * unit,
                        angle: p.angle,
                        stretch: 1 + CGFloat(min(0.6, speed / 1500)))
        }
    }

    /// An orb's outline: a circle, drawn longer along its path when it moves fast.
    private func outline(_ p: Pose, scale: CGFloat = 1) -> Path {
        let r = p.radius * scale
        let long = r * p.stretch, short = r / p.stretch.squareRoot()
        return Path(ellipseIn: CGRect(x: -long, y: -short, width: 2 * long, height: 2 * short))
            .applying(CGAffineTransform(rotationAngle: p.angle + .pi / 2))
            .applying(CGAffineTransform(translationX: p.x, y: p.y))
    }

    /// The merged shape: the orbs blurred together and cut at half strength, so orbs that come
    /// close join with a smooth bridge and part again as they move apart.
    private func liquid(_ poses: [Pose]) -> some View {
        Canvas { context, _ in
            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
            context.addFilter(.blur(radius: size.width * 0.03))
            context.drawLayer { layer in
                for p in poses { layer.fill(outline(p), with: .color(.white)) }
            }
        }
    }

    /// Each orb's colour, brightest toward the upper left like a lit sphere. Underneath, a wide
    /// soft wash of every orb's colour, so a bridge between two orbs blends the two.
    private func colour(_ poses: [Pose]) -> some View {
        Canvas { context, _ in
            var wash = context
            wash.addFilter(.blur(radius: size.width * 0.05))
            for (i, p) in poses.enumerated() {
                wash.fill(outline(p, scale: 1.3), with: .color(Self.orbs[i].colors[1]))
            }
            for (i, p) in poses.enumerated() {
                let colors = Self.orbs[i].colors
                let light = CGPoint(x: p.x - p.radius * 0.3, y: p.y - p.radius * 0.35)
                context.fill(outline(p),
                             with: .radialGradient(Gradient(stops: [.init(color: colors[0], location: 0),
                                                                    .init(color: colors[1], location: 0.5),
                                                                    .init(color: colors[2], location: 0.85),
                                                                    .init(color: colors[2].opacity(0), location: 1)]),
                                                   center: light, startRadius: 0, endRadius: p.radius * 1.55))
            }
        }
    }

    /// Shade inside the edge of the merged shape (not of each orb), so joined orbs read as one
    /// rounded body of liquid with no seam where they meet.
    private func edgeShade(_ poses: [Pose]) -> some View {
        Color.black.opacity(0.3)
            .mask {
                Rectangle()
                    .overlay(liquid(poses).blur(radius: size.width * 0.03).blendMode(.destinationOut))
                    .compositingGroup()
            }
    }

    /// A soft window of light on each orb.
    private func highlights(_ poses: [Pose]) -> some View {
        Canvas { context, _ in
            for p in poses {
                var glint = context
                glint.addFilter(.blur(radius: p.radius * 0.12))
                glint.fill(Path(ellipseIn: CGRect(x: p.x - p.radius * 0.6, y: p.y - p.radius * 0.72,
                                                  width: p.radius * 0.72, height: p.radius * 0.46)),
                           with: .color(.white.opacity(0.42)))
            }
        }
    }
}

/// 0 before `a`, 1 after `b`, eased in and out between.
private func smoothstep(_ a: Double, _ b: Double, _ t: Double) -> Double {
    let x = min(1, max(0, (t - a) / (b - a)))
    return x * x * (3 - 2 * x)
}
