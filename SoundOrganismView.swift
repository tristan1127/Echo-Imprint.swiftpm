import SwiftUI

struct SoundOrganismView: View {

    let amplitude: Float
    let frequency: Float
    let rhythm: Float

    @State private var growth: CGFloat = 0
    @State private var smoothedAmplitude: Float = 0
    @State private var smoothedFrequency: Float = 0
    @State private var smoothedRhythm: Float = 0

    struct Ring {
        var radius: CGFloat
        var opacity: Double
        var spawnTime: Double
    }
    @State private var rings: [Ring] = []
    @State private var lastRingTimestamp: Double = 0

    private let baseRadius: CGFloat = 40
    private let maxRadius: CGFloat = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let timeSpeed = 0.6 + Double(smoothedRhythm) * 0.8
            let t = time * timeSpeed

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let currentRadius = baseRadius + growth
                let saturation = maxRadius - currentRadius
                let directionShift = sin(time * 0.4) * CGFloat(smoothedFrequency) * 25
                let outerCenter = CGPoint(x: center.x + directionShift, y: center.y)

                let glowRadius = currentRadius + 40
                var glowPath = Path()
                glowPath.addEllipse(in: CGRect(x: center.x - glowRadius, y: center.y - glowRadius, width: glowRadius * 2, height: glowRadius * 2))
                context.fill(glowPath, with: .radialGradient(
                    Gradient(colors: [Color.purple.opacity(0.08), Color.clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: glowRadius
                ))

                for ring in rings {
                    let tRing = ring.spawnTime
                    var ringPath = Path()
                    let segments = 120
                    for i in 0...segments {
                        let angle = (Double(i) / Double(segments)) * 2 * Double.pi
                        var deform = sin(angle * 3 + tRing * 0.6) * Double(ring.radius * 0.12)
                            + sin(angle * 5 + tRing * 0.4) * Double(ring.radius * 0.07)
                            + sin(angle * 7 + tRing * 0.9) * Double(ring.radius * 0.04)
                        let r = ring.radius + CGFloat(deform)
                        let x = outerCenter.x + cos(angle) * r
                        let y = outerCenter.y + sin(angle) * r
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
                    var deform = sin(angle * 3 + t * 0.6) * Double(growth * 0.12)
                        + sin(angle * 5 + t * 0.4) * Double(growth * 0.07)
                        + sin(angle * 7 + t * 0.9) * Double(growth * 0.04)
                    if smoothedFrequency > 0.6 {
                        deform *= 1.4
                        deform += sin(angle * 9 + t * 1.8) * Double(growth * 0.05)
                    }
                    let r = currentRadius + CGFloat(deform)
                    let x = outerCenter.x + cos(angle) * r
                    let y = outerCenter.y + sin(angle) * r
                    if i == 0 { outerPath.move(to: CGPoint(x: x, y: y)) }
                    else { outerPath.addLine(to: CGPoint(x: x, y: y)) }
                }
                outerPath.closeSubpath()

                let freqNorm = min(1.0, max(0, Double(smoothedFrequency)))
                let centerColor = Color(hue: 0.55 + freqNorm * 0.2, saturation: 0.7, brightness: 1).opacity(0.18)
                let fillGradient = Gradient(colors: [centerColor, Color.purple.opacity(0.06)])
                context.fill(outerPath, with: .radialGradient(fillGradient, center: outerCenter, startRadius: 0, endRadius: currentRadius + 30))
                context.stroke(outerPath, with: .color(Color.white.opacity(0.4)), lineWidth: 1)

                let innerRadiusScale: CGFloat = 0.75
                let innerBaseRadius = currentRadius * innerRadiusScale
                var innerPath = Path()
                for i in 0...outerSegments {
                    let angle = (Double(i) / Double(outerSegments)) * 2 * Double.pi
                    var deform = sin(angle * 3 + t * 0.5) * Double(growth * 0.06)
                        + sin(angle * 5 + t * 0.3) * Double(growth * 0.04)
                        + sin(angle * 7 + t * 0.6) * Double(growth * 0.02)
                    if smoothedFrequency > 0.6 { deform *= 1.4 }
                    let r = innerBaseRadius + CGFloat(deform)
                    let x = outerCenter.x + cos(angle) * r
                    let y = outerCenter.y + sin(angle) * r
                    if i == 0 { innerPath.move(to: CGPoint(x: x, y: y)) }
                    else { innerPath.addLine(to: CGPoint(x: x, y: y)) }
                }
                innerPath.closeSubpath()
                context.fill(innerPath, with: .color(Color.white.opacity(0.12)))
            }
            .onChange(of: timeline.date) { _ in
                smoothedAmplitude += (amplitude - smoothedAmplitude) * 0.08
                smoothedFrequency += (frequency - smoothedFrequency) * 0.05
                smoothedRhythm += (rhythm - smoothedRhythm) * 0.08
                let currentRadius = baseRadius + growth
                let saturation = maxRadius - currentRadius
                growth += CGFloat(smoothedAmplitude) * 0.6 * (saturation / maxRadius)
                growth *= 0.996

                let time = timeline.date.timeIntervalSinceReferenceDate
                if lastRingTimestamp == 0 { lastRingTimestamp = time }
                if time - lastRingTimestamp >= 0.25 {
                    if smoothedAmplitude > 0.05 {
                        rings.append(Ring(radius: currentRadius, opacity: 0.35, spawnTime: time))
                    }
                    lastRingTimestamp = time
                }
                rings = rings.map { Ring(radius: $0.radius, opacity: $0.opacity - 0.004, spawnTime: $0.spawnTime) }.filter { $0.opacity > 0 }
            }
        }
        .frame(width: 320, height: 320)
        .overlay(alignment: .center) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 72, height: 72)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.blue.opacity(0.15), radius: 12)
        }
        .transaction { transaction in transaction.animation = nil }
    }
}
