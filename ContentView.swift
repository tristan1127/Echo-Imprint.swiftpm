import AVFoundation
import SwiftUI

struct ContentView: View {

    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var specimenStore = SpecimenStore()
    @State private var pulseScale: CGFloat = 1.0
    @State private var wasRecording: Bool = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                titleArea
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                // Organism
                SoundOrganismView(
                    amplitude: audioRecorder.currentAmplitude,
                    frequency: audioRecorder.currentFrequency,
                    rhythm: audioRecorder.currentRhythm,
                    onGrowthUpdate: { growth in
                        audioRecorder.lastGrowth = growth
                    }
                )
                .transaction { $0.animation = nil }

                // Record controls
                VStack(spacing: 12) {
                    recordButton
                    statusText
                }
                .padding(.top, 8)

                // Specimen list
                specimenList
                    .padding(.top, 16)
            }
        }
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if isRecording {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
                if wasRecording {
                    // Save specimen with audio file
                    specimenStore.save(
                        amplitude: audioRecorder.currentAmplitude,
                        frequency: audioRecorder.currentFrequency,
                        rhythm: audioRecorder.currentRhythm,
                        growth: audioRecorder.lastGrowth,
                        audioURL: audioRecorder.lastRecordingURL
                    )
                }
            }
            wasRecording = isRecording
        }
    }

    // MARK: - Title

    private var titleArea: some View {
        VStack(spacing: 6) {
            Text("Echo Imprint")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(.label))
            Text("Visualize the sound around you")
                .font(.system(size: 14))
                .foregroundColor(Color(.systemGray))
            Divider().padding(.top, 12)
        }
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button(action: {
            if audioRecorder.isRecording {
                audioRecorder.stopRecording()
            } else {
                Task {
                    await audioRecorder.startRecording()
                }
            }
        }) {
            ZStack {
                if audioRecorder.isRecording {
                    let outerScale = 1.0 + (pulseScale - 1.0) * (0.35 / 0.08)
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 88, height: 88)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        .shadow(color: Color.red.opacity(0.25), radius: 16)
                        .scaleEffect(outerScale)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        .shadow(color: Color.red.opacity(0.3), radius: 20, x: 0, y: 8)
                        .scaleEffect(pulseScale)

                    Image(systemName: "stop.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 88, height: 88)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Color(.label))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Status

    private var statusText: some View {
        Text(audioRecorder.isRecording ? "Recording..." : "Tap to record")
            .font(.system(size: 13))
            .foregroundColor(Color(.systemGray))
            .animation(.easeInOut(duration: 0.2), value: audioRecorder.isRecording)
    }

    // MARK: - Specimen List

    private var specimenList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                if specimenStore.specimens.isEmpty {
                    Text("Your sound memories will appear here")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    ForEach(specimenStore.specimens) { specimen in
                        SpecimenCardView(
                            specimen: specimen,
                            onRename: { newName in
                                specimenStore.rename(specimen: specimen, to: newName)
                            }
                        )
                    }
                    .onDelete { offsets in
                        specimenStore.delete(at: offsets)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Animations

    private func startPulseAnimation() {
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

#Preview {
    ContentView()
}
