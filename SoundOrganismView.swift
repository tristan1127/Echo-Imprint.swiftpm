import SwiftUI

struct SoundOrganismView: View {

    let amplitude: Float
    let frequency: Float
    let rhythm: Float
    let size: CGFloat
    let isFrozen: Bool
    let frozenGrowth: Float
    let onGrowthUpdate: ((Float) -> Void)?

    init(
        amplitude: Float,
        frequency: Float,
        rhythm: Float,
        size: CGFloat = 320,
        isFrozen: Bool = false,
        frozenGrowth: Float = 0,
        onGrowthUpdate: ((Float) -> Void)? = nil
    ) {
        self.amplitude = amplitude
        self.frequency = frequency
        self.rhythm = rhythm
        self.size = size
        self.isFrozen = isFrozen
        self.frozenGrowth = frozenGrowth
        self.onGrowthUpdate = onGrowthUpdate
    }

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
    private let maxRadius: Double = 150

    var body: some View {
        if isFrozen {
            frozenBody
        } else {
            liveBody
        }
    }

    private var frozenBody: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let growthValue = Double(frozenGrowth)
            let currentRadius = baseRadius + growthValue
            let pulseStrength = 0.06 + Double(rhythm) * 0.16

            let glowRadius = currentRadius + 40
            var glowPath = Path()
            glowPath.addEllipse(in: CGRect(x: center.x - CGFloat(glowRadius), y: center.y - CGFloat(glowRadius), width: CGFloat(glowRadius * 2), height: CGFloat(glowRadius * 2)))
            context.fill(glowPath, with: .radialGradient(
                Gradient(colors: [Color.purple.opacity(0.08), Color.clear]),
                center: center,
                startRadius: 0,
                endRadius: CGFloat(glowRadius)
            ))

            var outerPath = Path()
            let outerSegments = 160
            let phaseValue: Double = 0
            let smoothedFrequencyValue = Double(frequency)

            for i in 0...outerSegments {
                let angle = (Double(i) / Double(outerSegments)) * 2 * Double.pi
                var deform = sin(angle * 3 + phaseValue * 0.6) * (growthValue * 0.24)
                    + sin(angle * 5 + phaseValue * 0.4) * (growthValue * 0.14)
                    + sin(angle * 7 + phaseValue * 0.9) * (growthValue * 0.08)
                if smoothedFrequencyValue > 0.6 {
                    deform *= 1.4
                    deform += sin(angle * 9 + phaseValue * 1.8) * (growthValue * 0.10)
                }
                let r = currentRadius + deform
                let x = center.x + CGFloat(cos(angle) * r)
                let y = center.y + CGFloat(sin(angle) * r)
                if i == 0 { outerPath.move(to: CGPoint(x: x, y: y)) }
                else { outerPath.addLine(to: CGPoint(x: x, y: y)) }
            }
            outerPath.closeSubpath()

            let freqNorm = min(1.0, max(0, smoothedFrequencyValue))
            let centerColor = Color(hue: 0.55 + freqNorm * 0.2, saturation: 0.7, brightness: 1).opacity(0.18)
            let fillGradient = Gradient(colors: [centerColor, Color.purple.opacity(0.06)])
            context.fill(outerPath, with: .radialGradient(fillGradient, center: center, startRadius: 0, endRadius: CGFloat(currentRadius + 30)))
            context.stroke(outerPath, with: .color(Color.white.opacity(0.4)), lineWidth: 1)

            let innerRadiusScale: Double = 0.75
            let innerBaseRadius = currentRadius * innerRadiusScale
            var innerPath = Path()
            for i in 0...outerSegments {
                let angle = (Double(i) / Double(outerSegments)) * 2 * Double.pi
                var deform = sin(angle * 3 + phaseValue * 0.5) * (growthValue * 0.12)
                    + sin(angle * 5 + phaseValue * 0.3) * (growthValue * 0.08)
                    + sin(angle * 7 + phaseValue * 0.6) * (growthValue * 0.04)
                if smoothedFrequencyValue > 0.6 { deform *= 1.4 }
                let r = innerBaseRadius + deform
                let x = center.x + CGFloat(cos(angle) * r)
                let y = center.y + CGFloat(sin(angle) * r)
                if i == 0 { innerPath.move(to: CGPoint(x: x, y: y)) }
                else { innerPath.addLine(to: CGPoint(x: x, y: y)) }
            }
            innerPath.closeSubpath()
            context.fill(innerPath, with: .color(Color.white.opacity(0.12)))
        }
        .frame(width: size, height: size)
        .overlay(alignment: .center) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(
                    width: 64 + CGFloat(amplitude) * 40,
                    height: 64 + CGFloat(amplitude) * 40
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.blue.opacity(0.15), radius: 12)
        }
        .transaction { transaction in transaction.animation = nil }
    }

    private var liveBody: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let currentRadius = baseRadius + growth
                let pulseStrength = 0.06 + smoothedRhythm * 0.16

                let glowRadius = currentRadius + 40
                var glowPath = Path()
                glowPath.addEllipse(in: CGRect(x: center.x - CGFloat(glowRadius), y: center.y - CGFloat(glowRadius), width: CGFloat(glowRadius * 2), height: CGFloat(glowRadius * 2)))
                context.fill(glowPath, with: .radialGradient(
                    Gradient(colors: [Color.purple.opacity(0.08), Color.clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: CGFloat(glowRadius)
                ))

                for ring in rings {
                    var ringPath = Path()
                    let segments = 120
                    for i in 0...segments {
                        let angle = (Double(i) / Double(segments)) * 2 * Double.pi
                        let deform =
                            sin(angle * 3 + ring.spawnPhase * 0.6) * (ring.radius * 0.24) +
                            sin(angle * 5 + ring.spawnPhase * 0.4) * (ring.radius * 0.14) +
                            sin(angle * 7 + ring.spawnPhase * 0.9) * (ring.radius * 0.08)
                        let r = ring.radius + deform
                        let x = center.x + CGFloat(cos(angle) * r)
                        let y = center.y + CGFloat(sin(angle) * r)
                        if i == 0 { ringPath.move(to: CGPoint(x: x, y: y)) }
                        else { ringPath.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    ringPath.closeSubpath()
                    context.stroke(ringPath, with: .color(Color.blue.opacity(ring.opacity)), lineWidth: 0.8)
                }

                var outerPath = Path()
                let outerSegments = 160
                for i in 0...outerSegments {
                    let angle = (Double(i) / Double(outerSegments)) * 2 * Double.pi
                    var deform = sin(angle * 3 + phase * 0.6) * (growth * 0.24)
                        + sin(angle * 5 + phase * 0.4) * (growth * 0.14)
                        + sin(angle * 7 + phase * 0.9) * (growth * 0.08)
                    if smoothedFrequency > 0.6 {
                        deform *= 1.4
                        deform += sin(angle * 9 + phase * 1.8) * (growth * 0.10)
                    }
                    let r = currentRadius + deform
                    let x = center.x + CGFloat(cos(angle) * r)
                    let y = center.y + CGFloat(sin(angle) * r)
                    if i == 0 { outerPath.move(to: CGPoint(x: x, y: y)) }
                    else { outerPath.addLine(to: CGPoint(x: x, y: y)) }
                }
                outerPath.closeSubpath()

                let freqNorm = min(1.0, max(0, Double(smoothedFrequency)))
                let centerColor = Color(hue: 0.55 + freqNorm * 0.2, saturation: 0.7, brightness: 1).opacity(0.18)
                let fillGradient = Gradient(colors: [centerColor, Color.purple.opacity(0.06)])
                context.fill(outerPath, with: .radialGradient(fillGradient, center: center, startRadius: 0, endRadius: CGFloat(currentRadius + 30)))
                context.stroke(outerPath, with: .color(Color.white.opacity(0.4)), lineWidth: 1)

                let innerRadiusScale: Double = 0.75
                let innerBaseRadius = currentRadius * innerRadiusScale
                var innerPath = Path()
                for i in 0...outerSegments {
                    let angle = (Double(i) / Double(outerSegments)) * 2 * Double.pi
                    var deform = sin(angle * 3 + phase * 0.5) * (growth * 0.12)
                        + sin(angle * 5 + phase * 0.3) * (growth * 0.08)
                        + sin(angle * 7 + phase * 0.6) * (growth * 0.04)
                    if smoothedFrequency > 0.6 { deform *= 1.4 }
                    let r = innerBaseRadius + deform
                    let x = center.x + CGFloat(cos(angle) * r)
                    let y = center.y + CGFloat(sin(angle) * r)
                    if i == 0 { innerPath.move(to: CGPoint(x: x, y: y)) }
                    else { innerPath.addLine(to: CGPoint(x: x, y: y)) }
                }
                innerPath.closeSubpath()
                context.fill(innerPath, with: .color(Color.white.opacity(0.12)))
            }
            .onChange(of: timeline.date) { _ in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let delta = lastTime == 0 ? 0.016 : min(now - lastTime, 0.05)
                lastTime = now

                updateSmoothing()

                phase += smoothedFrequency * delta * 4.0

                let radiusBeforeGrowth = baseRadius + growth
                let saturation = maxRadius - radiusBeforeGrowth
                let growthDelta = smoothedAmplitude * 1.8 * (saturation / maxRadius)
                growth += max(0, growthDelta)
                growth *= 0.996
                onGrowthUpdate?(Float(growth))

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
                if lastRingTime >= 0.3, smoothedAmplitude > 0.02 {
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
            .frame(width: size, height: size)
        }
        .overlay(alignment: .center) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(
                    width: 64 + CGFloat(smoothedAmplitude) * 40,
                    height: 64 + CGFloat(smoothedAmplitude) * 40
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.blue.opacity(0.15), radius: 12)
                .scaleEffect(coreScale)
        }
        .transaction { transaction in transaction.animation = nil }
    }

    private func updateSmoothing() {
        smoothedAmplitude += (Double(amplitude) - smoothedAmplitude) * 0.08
        smoothedFrequency += (Double(frequency) - smoothedFrequency) * 0.05
        smoothedRhythm += (Double(rhythm) - smoothedRhythm) * 0.06
    }
}
