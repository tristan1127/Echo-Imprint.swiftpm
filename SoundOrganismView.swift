import SwiftUI

struct SoundOrganismView: View {

    let amplitude: Float
    let frequency: Float
    let rhythm: Float

    @State private var phase: Double = 0
    @State private var growth: Double = 0
    @State private var smoothedAmplitude: Double = 0
    @State private var smoothedFrequency: Double = 0
    @State private var smoothedRhythm: Double = 0
    @State private var rings: [Ring] = []
    @State private var lastRingTime: Double = 0
    @State private var isSilentBreathing: Bool = false
    @State private var coreScale: CGFloat = 1.0
    @State private var lastTime: TimeInterval = 0

    struct Ring {
        var radius: Double
        var opacity: Double
        var spawnPhase: Double
    }

    private let baseRadius: Double = 40

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let currentRadius = baseRadius + growth
                let complexity = 2.0 + smoothedFrequency * 9.0
                let pulseStrength = 0.06 + smoothedRhythm * 0.16

                let glowRadius = currentRadius + 40
                var glowPath = Path()
                glowPath.addEllipse(
                    in: CGRect(
                        x: center.x - CGFloat(glowRadius),
                        y: center.y - CGFloat(glowRadius),
                        width: CGFloat(glowRadius * 2),
                        height: CGFloat(glowRadius * 2)
                    )
                )
                context.fill(
                    glowPath,
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.purple.opacity(0.06),
                            .clear,
                        ]),
                        center: center,
                        startRadius: 0,
                        endRadius: CGFloat(glowRadius)
                    )
                )

                for ring in rings {
                    var ringPath = Path()
                    let segments = 120
                    for i in 0...segments {
                        let angle = (Double(i) / Double(segments)) * 2 * .pi
                        let deform =
                            sin(angle * 3 + ring.spawnPhase * 0.6) * ring.radius * pulseStrength +
                            sin(angle * 5 + ring.spawnPhase * 0.4) * ring.radius * (pulseStrength * 0.5) +
                            sin(angle * 7 + ring.spawnPhase * 0.9) * 3.0
                        let r = ring.radius + deform
                        let x = center.x + CGFloat(cos(angle) * r)
                        let y = center.y + CGFloat(sin(angle) * r)
                        if i == 0 {
                            ringPath.move(to: CGPoint(x: x, y: y))
                        } else {
                            ringPath.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    ringPath.closeSubpath()
                    context.stroke(
                        ringPath,
                        with: .color(Color.blue.opacity(ring.opacity)),
                        lineWidth: 0.8
                    )
                }

                let lobeCount = 4.0 + smoothedFrequency * 6.0
                let mainDeformScale = currentRadius * 0.12 + growth * pulseStrength * 0.25
                var mainPath = Path()
                let segments = 280
                for i in 0...segments {
                    let angle = (Double(i) / Double(segments)) * 2 * .pi
                    let deform =
                        sin(angle * lobeCount + phase) * mainDeformScale +
                        sin(angle * lobeCount * 2 + phase) * mainDeformScale * 0.35 +
                        sin(angle * lobeCount * 0.5 + phase) * mainDeformScale * 0.2
                    let r = currentRadius + deform
                    let x = center.x + CGFloat(cos(angle) * r)
                    let y = center.y + CGFloat(sin(angle) * r)
                    if i == 0 {
                        mainPath.move(to: CGPoint(x: x, y: y))
                    } else {
                        mainPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                mainPath.closeSubpath()

                let hueCenter = 0.58 + smoothedFrequency * 0.15
                let centerColor = Color(
                    hue: hueCenter,
                    saturation: 0.75,
                    brightness: 1.0
                ).opacity(0.15 + 0.03 * smoothedFrequency)
                let edgeColor = Color(
                    hue: min(1.0, hueCenter + 0.12),
                    saturation: 0.7,
                    brightness: 1.0
                ).opacity(0.04 + 0.01 * (1 - smoothedFrequency))

                let fillGradient = Gradient(colors: [centerColor, edgeColor])
                context.fill(
                    mainPath,
                    with: .radialGradient(
                        fillGradient,
                        center: center,
                        startRadius: 0,
                        endRadius: CGFloat(currentRadius + 30)
                    )
                )

                context.stroke(
                    mainPath,
                    with: .color(Color.white.opacity(0.35)),
                    lineWidth: 1
                )
            }
            .onChange(of: timeline.date) { _ in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let delta = lastTime == 0 ? 0.016 : min(now - lastTime, 0.05)
                lastTime = now

                updateSmoothing()

                phase += smoothedFrequency * delta * 14.0
                growth += smoothedAmplitude * delta * 20.0
                growth *= pow(0.994, delta * 60)

                if smoothedAmplitude > 0.02 {
                    isSilentBreathing = false
                    coreScale = 1.0
                } else {
                    if !isSilentBreathing {
                        isSilentBreathing = true
                        withAnimation(.easeInOut(duration: 1.4).repeatCount(1, autoreverses: true)) {
                            coreScale = 1.03
                        }
                    }
                }

                let currentRadius = baseRadius + growth
                lastRingTime += delta
                if lastRingTime >= 0.3, smoothedAmplitude > 0.04 {
                    rings.append(Ring(radius: currentRadius, opacity: 0.3, spawnPhase: phase))
                    lastRingTime = 0
                }

                rings = rings
                    .map { Ring(radius: $0.radius, opacity: $0.opacity - 0.003, spawnPhase: $0.spawnPhase) }
                    .filter { $0.opacity > 0 }
            }
            .onChange(of: amplitude) { _ in updateSmoothing() }
            .onChange(of: frequency) { _ in updateSmoothing() }
            .onChange(of: rhythm) { _ in updateSmoothing() }
            .frame(width: 320, height: 320)
        }
        .overlay(alignment: .center) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(
                    width: 64 + CGFloat(smoothedFrequency) * 16,
                    height: 64 + CGFloat(smoothedFrequency) * 16
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.blue.opacity(0.12), radius: 10)
                .scaleEffect(coreScale)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func updateSmoothing() {
        smoothedAmplitude += (Double(amplitude) - smoothedAmplitude) * 0.08
        smoothedFrequency += (Double(frequency) - smoothedFrequency) * 0.05
        smoothedRhythm += (Double(rhythm) - smoothedRhythm) * 0.06
    }
}
