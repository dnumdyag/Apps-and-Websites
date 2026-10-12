import SwiftUI

/// The opening, about five seconds before Mia's interview (option 1 on the "Coach Mia Splash
/// Screens" page, as Ed asked on 12 October 2026). Four soft orbs of light drift in, pull toward
/// each other and blend where they meet; the gold one whips round and slows; they settle into a
/// slow ring round the M. Skip moves straight on.
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

/// The orbs: four soft orbs of light, blurred together and blended so their light adds up where
/// they overlap. Each circles a shared centre while the circles tighten into an even ring round
/// the M; orbs that pass close pull together and swell; the gold one whips round at 1.5 s
/// (540 degrees, slowing as it goes) and draws out with the speed. Every position is a smooth
/// function of time, so nothing jumps.
private struct OrbField: View {
    let t: Double
    let size: CGSize

    /// The ring's centre, as a fraction of the screen's height.
    static let centreY: CGFloat = 0.44

    private struct Orb {
        /// The bright core and the softer body of the light, which fades out at 70% of the radius.
        let core: Color, body: Color
        /// Sizes and distances in hundredths of the screen's width; angles in radians.
        let diameter: Double
        let r0: Double, r1: Double, a0: Double, w: Double
    }

    private static let orbs: [Orb] = [
        Orb(core: Color(red: 246 / 255, green: 206 / 255, blue: 120 / 255),
            body: Color(red: 201 / 255, green: 154 / 255, blue: 60 / 255, opacity: 0.8),
            diameter: 50, r0: 30, r1: 19, a0: -0.6, w: 0.8),
        Orb(core: Color(red: 226 / 255, green: 244 / 255, blue: 235 / 255, opacity: 0.92),
            body: Color(red: 190 / 255, green: 222 / 255, blue: 206 / 255, opacity: 0.6),
            diameter: 42, r0: 27, r1: 21, a0: 1.6, w: -0.55),
        Orb(core: Color(red: 255 / 255, green: 240 / 255, blue: 196 / 255, opacity: 0.95),
            body: Color(red: 235 / 255, green: 208 / 255, blue: 138 / 255, opacity: 0.68),
            diameter: 38, r0: 34, r1: 18, a0: 3.3, w: 1.0),
        Orb(core: Color(red: 70 / 255, green: 190 / 255, blue: 140 / 255, opacity: 0.78),
            body: Color(red: 47 / 255, green: 163 / 255, blue: 107 / 255, opacity: 0.5),
            diameter: 56, r0: 22, r1: 22, a0: 4.6, w: 0.35),
    ]

    /// Back to front: the emerald glow behind, the gold on top.
    private static let drawOrder = [3, 1, 2, 0]

    private struct Pose {
        var x: CGFloat, y: CGFloat, diameter: CGFloat
        /// Direction of travel round the centre, and how far the orb is drawn out along it.
        var angle: Double, stretch: CGFloat
    }

    var body: some View {
        let poses = poses()
        ZStack {
            ForEach(Self.drawOrder, id: \.self) { i in
                let p = poses[i], orb = Self.orbs[i]
                Circle()
                    .fill(RadialGradient(stops: [.init(color: orb.core, location: 0),
                                                 .init(color: orb.body, location: 0.34),
                                                 .init(color: orb.body.opacity(0), location: 0.7)],
                                         center: .center, startRadius: 0, endRadius: p.diameter / 2))
                    .frame(width: p.diameter, height: p.diameter)
                    .scaleEffect(x: p.stretch, y: 1 / p.stretch.squareRoot())
                    .rotationEffect(.radians(p.angle + .pi / 2))
                    .blendMode(.screen)
                    .position(x: p.x, y: p.y)
            }
        }
        .compositingGroup()
        .blur(radius: size.width * 0.026)
        .opacity(smoothstep(0, 1.1, t))
    }

    private func poses() -> [Pose] {
        let unit = size.width / 100
        let gather = smoothstep(0.9, 3.8, t)
        let fade = smoothstep(0, 1.1, t)
        let spinStart = 1.5, turn = 3 * Double.pi, settle = 0.3
        func spin(_ t: Double) -> Double { t < spinStart ? 0 : turn * (1 - exp(-(t - spinStart) / settle)) }
        let spinSpeed = t < spinStart ? 0 : turn / settle * exp(-(t - spinStart) / settle)

        var points: [(x: Double, y: Double, swell: Double, angle: Double, r: Double)] = Self.orbs.enumerated().map { i, orb in
            // Free orbits at first; as they gather, each eases onto an even ring that turns slowly.
            func free(_ t: Double) -> Double { orb.a0 + orb.w * t + (i == 0 ? spin(t) : 0) }
            func ring(_ t: Double) -> Double { 0.5 * t + Double(i) * .pi / 2 + 0.4 }
            // The whole turns to add are fixed once (by where the orb ends up), so the angle
            // never jumps a full turn part way through.
            let turns = ((free(3.8) - ring(3.8)) / (2 * .pi)).rounded()
            let gap = ring(t) - free(t) + turns * 2 * .pi
            let angle = free(t) + gather * gap
            let r = orb.r0 * (1 - gather) + orb.r1 * gather
            return (r * cos(angle), r * sin(angle) * 0.9, 1, angle, r)
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
                let swell = 0.2 * max(0, 1 - d / 28)
                points[i].swell += swell
                points[j].swell += swell
            }
        }
        return points.enumerated().map { i, p in
            let breathe = 1 + 0.035 * sin(2.1 * t + Double(i))
            let scale = p.swell * (0.55 + 0.45 * fade) * breathe
            let speed = i == 0 ? spinSpeed * p.r : 0
            return Pose(x: size.width / 2 + CGFloat(p.x) * unit,
                        y: size.height * Self.centreY + CGFloat(p.y) * unit,
                        diameter: CGFloat(Self.orbs[i].diameter * scale) * unit,
                        angle: p.angle,
                        stretch: 1 + CGFloat(min(0.5, speed / 1500)))
        }
    }
}

/// 0 before `a`, 1 after `b`, eased in and out between.
private func smoothstep(_ a: Double, _ b: Double, _ t: Double) -> Double {
    let x = min(1, max(0, (t - a) / (b - a)))
    return x * x * (3 - 2 * x)
}
