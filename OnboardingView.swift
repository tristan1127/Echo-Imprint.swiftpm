import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var bodyOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var orbScale: CGFloat = 0.6
    @State private var orbOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background ambient orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hue: 0.62, saturation: 0.7, brightness: 0.6).opacity(0.35),
                            Color(hue: 0.72, saturation: 0.8, brightness: 0.4).opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .scaleEffect(orbScale)
                .opacity(orbOpacity)
                .blur(radius: 30)
                .offset(y: -60)

            VStack(spacing: 0) {
                Spacer()

                // Icon orb
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color(hue: 0.62, saturation: 0.6, brightness: 0.8).opacity(0.4), radius: 24)

                    Image(systemName: "waveform.and.mic")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(orbOpacity)
                .scaleEffect(orbScale)
                .padding(.bottom, 40)

                // Title
                Text("Echo Imprint")
                    .font(.system(size: 38, weight: .thin, design: .default))
                    .foregroundColor(.white)
                    .opacity(titleOpacity)
                    .padding(.bottom, 12)

                // Tagline
                Text("Every sound leaves a mark.")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color.white.opacity(0.5))
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 52)

                // Body text
                VStack(spacing: 20) {
                    narrativeLine(
                        icon: "mic.circle",
                        text: "Sound is the most fleeting thing we experience — gone the moment it arrives."
                    )
                    narrativeLine(
                        icon: "atom",
                        text: "Echo Imprint captures that instant and crystallizes it into a living visual form, shaped by the unique texture of your voice and world."
                    )
                    narrativeLine(
                        icon: "square.grid.2x2",
                        text: "Each recording becomes a specimen — a spatial memory you can return to."
                    )
                }
                .opacity(bodyOpacity)
                .padding(.horizontal, 36)

                Spacer()
                Spacer()

                // CTA button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text("Begin")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 52)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.white.opacity(0.25), radius: 16)
                }
                .buttonStyle(.plain)
                .opacity(buttonOpacity)
                .accessibilityLabel("Begin using Echo Imprint")
                .accessibilityHint("Double tap to enter the app")

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                orbScale = 1.0
                orbOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
                bodyOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(1.6)) {
                buttonOpacity = 1.0
            }
        }
    }

    private func narrativeLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(Color(hue: 0.62, saturation: 0.4, brightness: 0.9))
                .frame(width: 24)
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color.white.opacity(0.65))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}
