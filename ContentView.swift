import AVFoundation
import SwiftUI

struct ContentView: View {

    // MARK: - State

    @StateObject private var audioRecorder = AudioRecorder()
    @State private var pulseScale: CGFloat = 1.0

    // MARK: - Body

    var body: some View {
        ZStack {
            // Grouped background (adapts to light/dark mode)
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title area at top
                titleArea
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                Spacer()

                // Sound organism visualization
                SoundOrganismView(audioRecorder: audioRecorder)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .animation(nil, value: audioRecorder.isRecording)
                    .animation(nil, value: pulseScale)

                Spacer()

                // Center area with record button and playback
                VStack(spacing: 16) {
                    recordButton
                    statusText
                    playButton
                }

                Spacer()
            }
        }
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if isRecording {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
    }

    // MARK: - Title Area

    private var titleArea: some View {
        VStack(spacing: 8) {
            Text("Echo Imprint")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.black)

            Text("Capture the sound around you")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(.systemGray))

            Divider()
                .padding(.top, 16)
        }
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button(action: {
            if audioRecorder.isRecording {
                audioRecorder.stopRecording()
            } else {
                Task {
                    let success = await audioRecorder.startRecording()
                    print("Recording started: \(success)")
                }
            }
        }) {
            ZStack {
                if audioRecorder.isRecording {
                    // Calculate outer ring scale synchronized to pulseScale
                    // pulseScale: 1.0 to 1.08, outer ring: 1.0 to 1.35
                    let outerRingScale = 1.0 + (pulseScale - 1.0) * (1.35 - 1.0) / (1.08 - 1.0)

                    // Red tint base layer
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 88, height: 88)

                    // Pulsing outer glass ring (synchronized with center button)
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 88, height: 88)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: Color.red.opacity(0.25), radius: 16)
                    }
                    .scaleEffect(outerRingScale)

                    // Main button with material (synchronized pulse)
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: Color.red.opacity(0.3), radius: 20, x: 0, y: 8)
                        .scaleEffect(pulseScale)

                    Image(systemName: "stop.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                } else {
                    // Idle state - glass morphism button
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 88, height: 88)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    }

                    Image(systemName: "mic.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color(.label))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Status Text

    private var statusText: some View {
        Text(audioRecorder.isRecording ? "Recording..." : "Tap to record")
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(Color(.systemGray))
            .multilineTextAlignment(.center)
            .animation(.easeInOut(duration: 0.2), value: audioRecorder.isRecording)
    }

    // MARK: - Play Button

    private var playButton: some View {
        Button(action: {
            audioRecorder.playLastRecording()
        }) {
            Label(
                audioRecorder.lastRecordingURL == nil ? "No recording yet" : "Play last recording",
                systemImage: "play.fill"
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(audioRecorder.lastRecordingURL == nil ? Color(.systemGray) : Color(.systemBlue))
        }
        .disabled(audioRecorder.lastRecordingURL == nil || audioRecorder.isRecording || audioRecorder.isPlaying)
        .padding(.top, 8)
    }

    // MARK: - Animations

    private func startPulseAnimation() {
        // Single synchronized animation for both center button and outer ring
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            pulseScale = 1.08
        }
    }

    private func stopPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            pulseScale = 1.0
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
