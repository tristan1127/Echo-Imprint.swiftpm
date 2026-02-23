import SwiftUI

/// Glass Echo Seed – an organic, breathing visual form driven by sound.
struct SoundOrganismView: View {

    // MARK: - Input parameters

    let amplitude: Float
    let frequency: Float
    let rhythm: Float

    // MARK: - Growth system

    @State private var growth: CGFloat = 0
    @State private var smoothedAmplitude: Float = 0

    // MARK: - Ring system

    struct Ring {
        var radius: CGFloat
        var opacity: Double
    }

    @State private var rings: [Ring] = []
    @State private var lastRingTimestamp: TimeInterval = 0

    // MARK: - Body

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let time = now.timeIntervalSinceReferenceDate

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                // Advance internal simulation state for this frame.
                updateFrameState(now: now)

                let currentRadius = 40 + growth

                // Layer 1 — Outer glow
                drawOuterGlow(in: context, center: center, currentRadius: currentRadius)

                // Layer 2 — Historical rings
                drawHistoricalRings(
                    in: context,
                    center: center,
                    time: time,
                    currentRadius: currentRadius
                )

                // Layer 3 — Main organic shape
                drawMainOrganicShape(
                    in: context,
                    center: center,
                    time: time,
                    currentRadius: currentRadius
                )
            }
        }
        .frame(width: 320, height: 320)
        .overlay(alignment: .center) {
            // Layer 4 — Glass core center
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 72, height: 72) // radius 36
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.blue.opacity(0.15), radius: 12)
            }
        }
        .transaction { transaction in
            // Disable implicit animations – the motion is driven by TimelineView.
            transaction.animation = nil
        }
    }

    // MARK: - Frame update

    private func updateFrameState(now: Date) {
        let rawAmplitude = amplitude

        // Defer state mutation off the immediate render pass.
        DispatchQueue.main.async {
            // Growth system
            smoothedAmplitude += (rawAmplitude - smoothedAmplitude) * 0.08
            growth += CGFloat(smoothedAmplitude) * 0.4
            growth *= 0.993

            let currentRadius = 40 + growth

            // Ring emission every 0.25s when above threshold
            let t = now.timeIntervalSinceReferenceDate
            if lastRingTimestamp == 0 {
                lastRingTimestamp = t
            }

            let delta = t - lastRingTimestamp
            if delta >= 0.25 {
                if smoothedAmplitude > 0.05 {
                    rings.append(Ring(radius: currentRadius, opacity: 0.35))
                }
                lastRingTimestamp = t
            }

            // Ring evolution
            rings = rings
                .map { ring in
                    Ring(radius: ring.radius, opacity: ring.opacity - 0.004)
                }
                .filter { $0.opacity > 0 }
        }
    }

    // MARK: - Drawing helpers

    private func drawOuterGlow(
        in context: GraphicsContext,
        center: CGPoint,
        currentRadius: CGFloat
    ) {
        let glowRadius = currentRadius + 30

        var glowPath = Path()
        glowPath.addEllipse(
            in: CGRect(
                x: center.x - glowRadius,
                y: center.y - glowRadius,
                width: glowRadius * 2,
                height: glowRadius * 2
            )
        )

        let gradient = Gradient(colors: [
            Color.purple.opacity(0.08),
            Color.clear,
        ])

        context.fill(
            glowPath,
            with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: glowRadius
            )
        )
    }

    private func drawHistoricalRings(
        in context: GraphicsContext,
        center: CGPoint,
        time: TimeInterval,
        currentRadius: CGFloat
    ) {
        let segments = 120

        for ring in rings {
            var path = Path()

            for i in 0...segments {
                let angle = (Double(i) / Double(segments)) * 2 * Double.pi

                // Deformation: radius + sin(angle * 3 + time) * (currentRadius * 0.08)
                let deformation = sin(angle * 3 + time) * Double(currentRadius * 0.08)
                let r = ring.radius + CGFloat(deformation)

                let x = center.x + cos(angle) * r
                let y = center.y + sin(angle) * r

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            path.closeSubpath()

            context.stroke(
                path,
                with: .color(Color.blue.opacity(ring.opacity)),
                lineWidth: 0.8
            )
        }
    }

    private func drawMainOrganicShape(
        in context: GraphicsContext,
        center: CGPoint,
        time: TimeInterval,
        currentRadius: CGFloat
    ) {
        let segments = 160
        var path = Path()

        for i in 0...segments {
            let angle = (Double(i) / Double(segments)) * 2 * Double.pi

            // Deformed circle:
            // radius = currentRadius + sin(angle * 4 + time * 0.8) * (growth * 0.15)
            let deformation = sin(angle * 4 + time * 0.8) * Double(growth * 0.15)
            let r = currentRadius + CGFloat(deformation)

            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()

        // Fill: RadialGradient, Color.blue.opacity(0.15) to Color.purple.opacity(0.05)
        let fillGradient = Gradient(colors: [
            Color.blue.opacity(0.15),
            Color.purple.opacity(0.05),
        ])

        context.fill(
            path,
            with: .radialGradient(
                fillGradient,
                center: center,
                startRadius: 0,
                endRadius: currentRadius + 20
            )
        )

        // Stroke: Color.white.opacity(0.4), line width 1
        context.stroke(
            path,
            with: .color(Color.white.opacity(0.4)),
            lineWidth: 1
        )
    }
}
