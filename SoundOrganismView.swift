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
        amplitude: Float, frequency: Float, rhythm: Float,
        size: CGFloat = 360, isFrozen: Bool = false,
        frozenGrowth: Float = 0, onGrowthUpdate: ((Float) -> Void)? = nil
    ) {
        self.amplitude = amplitude; self.frequency = frequency
        self.rhythm = rhythm; self.size = size
        self.isFrozen = isFrozen; self.frozenGrowth = frozenGrowth
        self.onGrowthUpdate = onGrowthUpdate
    }

    @State private var phase: Double = 0
    @State private var growth: Double = 0
    @State private var smoothedAmplitude: Double = 0
    @State private var smoothedFrequency: Double = 0
    @State private var smoothedRhythm: Double = 0
    @State private var lastTime: Double = 0

    private let baseRadius: Double = 60
    private let maxGrowth: Double = 100

    private var accessibilityDescription: String {
        if amplitude < 0.02 {
            return "Sound organism at rest. Silent and waiting."
        }
        let ampDesc = amplitude > 0.6 ? "loud" : amplitude > 0.2 ? "moderate" : "quiet"
        let freqDesc = frequency > 0.6 ? "high-pitched" : frequency > 0.3 ? "mid-range" : "low-pitched"
        let rhythmDesc = rhythm > 0.6 ? "fast-pulsing" : rhythm > 0.3 ? "rhythmic" : "steady"
        return "A \(rhythmDesc), \(ampDesc), \(freqDesc) sound memory is growing."
    }

    var body: some View {
        if isFrozen {
            frozenCanvas
        } else {
            liveCanvas
        }
    }

    // MARK: - Live Canvas
    private var liveCanvas: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                drawCrystallization(
                    context: context,
                    size: size,
                    amplitude: smoothedAmplitude,
                    frequency: smoothedFrequency,
                    rhythm: smoothedRhythm,
                    growth: growth,
                    phase: phase
                )
            }
            .onChange(of: timeline.date) { newDate in
                let now = newDate.timeIntervalSinceReferenceDate
                let delta = lastTime == 0 ? 0.016 : min(now - lastTime, 0.05)
                lastTime = now

                // 平滑过渡，避免生硬跳动
                smoothedAmplitude += (Double(amplitude) - smoothedAmplitude) * 0.15
                smoothedFrequency += (Double(frequency) - smoothedFrequency) * 0.10
                smoothedRhythm    += (Double(rhythm)    - smoothedRhythm)    * 0.10

                // 只有在有声音时才发生显著相位流转
                let speed = 2.0 + smoothedAmplitude * 15.0
                phase += speed * delta

                // 记录生长的痕迹
                let remaining = max(0, maxGrowth - growth)
                growth += smoothedAmplitude * delta * 25.0 * (remaining / maxGrowth)
                growth *= pow(0.995, delta * 60.0) // 缓慢回落
                onGrowthUpdate?(Float(growth))
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isImage)
    }

    // MARK: - Frozen Canvas (The "Imprint")
    private var frozenCanvas: some View {
        Canvas { context, size in
            drawCrystallization(
                context: context,
                size: size,
                amplitude: Double(amplitude),
                frequency: Double(frequency),
                rhythm: Double(rhythm),
                growth: Double(frozenGrowth),
                phase: 2.4 // 冻结在一个好看的静态相位
            )
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Frozen sound memory. \(frequency > 0.6 ? "High-pitched" : "Low-pitched") and \(amplitude > 0.4 ? "energetic" : "calm").")
        .accessibilityAddTraits(.isImage)
    }

    // MARK: - Drawing Engine (Siri-like Aura)
    private func drawCrystallization(
        context: GraphicsContext, size: CGSize,
        amplitude: Double, frequency: Double, rhythm: Double,
        growth: Double, phase: Double
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let currentRadius = baseRadius + growth
        
        // 开启高亮混合模式，打造发光晶体质感
        var blendedContext = context
        blendedContext.blendMode = .plusLighter
        
        // 基于频率决定基础色调
        let hueBase = 0.55 + frequency * 0.35 // 从冷青色到紫粉色过渡
        let baseColor = Color(hue: hueBase, saturation: 0.8, brightness: 0.6)
        
        // 绘制三层不同动态的流体形态
        let layers = 3
        for i in 0..<layers {
            let layerPhase = phase + Double(i) * (.pi / 1.5)
            // 频率越高，折叠/对称的花瓣数越多 (3 到 8)
            let folds = floor(3.0 + frequency * 5.0)
            // 振幅决定形变程度，振幅为0时，形变为0，就是一个完美的圆
            let deformation = amplitude * currentRadius * (0.3 + Double(i) * 0.15)
            
            let path = makeSymmetricPath(
                center: center,
                radius: currentRadius - Double(i) * 10,
                folds: folds,
                deformation: deformation,
                phase: layerPhase
            )
            
            // 每一层颜色略微偏移，创造色散和深度感
            let layerColor = Color(hue: hueBase + Double(i)*0.08, saturation: 0.7, brightness: 0.5 + amplitude*0.2)
            
            blendedContext.fill(path, with: .color(layerColor.opacity(0.6 + amplitude * 0.4)))
            blendedContext.stroke(path, with: .color(Color.white.opacity(0.3 + amplitude * 0.5)), lineWidth: 1.5)
        }
        
        // 中心发光核
        let coreRadius = 20.0 + amplitude * 30.0
        let corePath = Path(ellipseIn: CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
        context.fill(corePath, with: .color(Color.white.opacity(0.8)))
        context.fill(corePath, with: .color(baseColor.opacity(0.5)))
    }

    // MARK: - Pure Symmetric Math
    private func makeSymmetricPath(center: CGPoint, radius: Double, folds: Double, deformation: Double, phase: Double) -> Path {
        var path = Path()
        let segments = 120
        
        for i in 0...segments {
            let angle = Double(i) / Double(segments) * .pi * 2
            
            // 创造对称的波纹。如果没有 deformation (即没有声音)，这里就是 0
            let primaryWave = sin(angle * folds + phase) * deformation
            let secondaryWave = cos(angle * (folds + 1) - phase * 0.8) * (deformation * 0.3)
            
            let r = max(5, radius + primaryWave + secondaryWave)
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}
