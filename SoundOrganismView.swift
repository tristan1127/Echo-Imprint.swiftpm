import SwiftUI
import Combine

struct SoundOrganismView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    // Smooth interpolation state
    @State private var smoothedAmplitude: Float = 0.0
    @State private var smoothedFrequency: Float = 0.0
    @State private var smoothedRhythm: Float = 0.0
    
    // Lerp factor for smooth transitions
    private let lerpFactor: Float = 0.15
    
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 0.016)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                // Update rotation angle (0.2 radians per second)
                let rotationAngle = timeline.date.timeIntervalSince1970 * 0.2
                
                // When amplitude is near zero, show quiet seed
                if smoothedAmplitude < 0.01 {
                    drawQuietSeed(context: context, center: center)
                } else {
                    drawPetalShape(context: context, center: center, size: size, rotationAngle: rotationAngle)
                }
            }
        }
        .frame(width: 300, height: 300)
        .transaction { transaction in
            transaction.animation = nil
        }
        .onChange(of: audioRecorder.currentAmplitude) { newValue in
            // Update without animation
            smoothedAmplitude = lerp(smoothedAmplitude, newValue, lerpFactor)
        }
        .onChange(of: audioRecorder.currentFrequency) { newValue in
            // Update without animation
            smoothedFrequency = lerp(smoothedFrequency, newValue, lerpFactor)
        }
        .onChange(of: audioRecorder.currentRhythm) { newValue in
            // Update without animation
            smoothedRhythm = lerp(smoothedRhythm, newValue, lerpFactor)
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            // Continuous smoothing updates at ~60fps (no animation)
            smoothedAmplitude = lerp(smoothedAmplitude, audioRecorder.currentAmplitude, lerpFactor)
            smoothedFrequency = lerp(smoothedFrequency, audioRecorder.currentFrequency, lerpFactor)
            smoothedRhythm = lerp(smoothedRhythm, audioRecorder.currentRhythm, lerpFactor)
        }
    }
    
    // MARK: - Drawing Methods
    
    private func drawQuietSeed(context: GraphicsContext, center: CGPoint) {
        let radius: CGFloat = 30
        
        // Draw soft circle with material effect
        let circle = Path { path in
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }
        
        // Use a soft gradient fill
        let gradient = Gradient(colors: [
            Color(.systemBlue).opacity(0.3),
            Color(.systemPurple).opacity(0.15)
        ])
        
        context.fill(circle, with: .radialGradient(
            gradient,
            center: center,
            startRadius: 0,
            endRadius: radius
        ))
    }
    
    private func drawPetalShape(context: GraphicsContext, center: CGPoint, size: CGSize, rotationAngle: Double) {
        // Calculate petal parameters
        let petalCount = Int(4 + smoothedFrequency * 8) // 4 to 12 petals
        let baseLength: CGFloat = 60 + CGFloat(smoothedAmplitude) * 120 // 60 to 180pt
        let baseWidth: CGFloat = 20 + CGFloat(smoothedRhythm) * 30 // Width variation
        
        // Create path for radial petal shape
        var path = Path()
        
        // Draw each petal
        for i in 0..<petalCount {
            let angle = (Double(i) / Double(petalCount)) * 2 * .pi + rotationAngle
            let petalLength = baseLength * (1.0 + CGFloat(smoothedRhythm) * 0.3) // Rhythm affects length variation
            
            // Petal tip position
            let tipX = center.x + cos(angle) * petalLength
            let tipY = center.y + sin(angle) * petalLength
            
            // Control points for bezier curve (creates organic petal shape)
            let controlAngle1 = angle - .pi / 6
            let controlAngle2 = angle + .pi / 6
            
            let control1X = center.x + cos(controlAngle1) * petalLength * 0.5
            let control1Y = center.y + sin(controlAngle1) * petalLength * 0.5
            
            let control2X = center.x + cos(controlAngle2) * petalLength * 0.5
            let control2Y = center.y + sin(controlAngle2) * petalLength * 0.5
            
            // Draw petal as bezier curve from center to tip
            if i == 0 {
                path.move(to: center)
            }
            path.addCurve(
                to: CGPoint(x: tipX, y: tipY),
                control1: CGPoint(x: control1X, y: control1Y),
                control2: CGPoint(x: control2X, y: control2Y)
            )
            
            // Draw back curve to create petal shape
            let backControl1X = tipX + cos(angle + .pi / 2) * baseWidth * 0.5
            let backControl1Y = tipY + sin(angle + .pi / 2) * baseWidth * 0.5
            
            let backControl2X = tipX - cos(angle + .pi / 2) * baseWidth * 0.5
            let backControl2Y = tipY - sin(angle + .pi / 2) * baseWidth * 0.5
            
            path.addCurve(
                to: center,
                control1: CGPoint(x: backControl1X, y: backControl1Y),
                control2: CGPoint(x: backControl2X, y: backControl2Y)
            )
        }
        
        path.closeSubpath()
        
        // Create gradient from center to edges
        let gradient = Gradient(colors: [
            Color(.systemBlue).opacity(0.6),
            Color(.systemPurple).opacity(0.3)
        ])
        
        // Fill with radial gradient
        context.fill(path, with: .radialGradient(
            gradient,
            center: center,
            startRadius: 0,
            endRadius: baseLength * 1.2
        ))
    }
    
    // MARK: - Helper Functions
    
    /// Linear interpolation between two values
    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + (b - a) * t
    }
}
