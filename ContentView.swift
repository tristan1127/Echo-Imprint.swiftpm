import AVFoundation
import SwiftUI

struct ContentView: View {

    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var specimenStore = SpecimenStore()
    @State private var pulseScale: CGFloat = 1.0
    @State private var wasRecording: Bool = false
    @State private var showLibrary: Bool = false

    var body: some View {
        ZStack {
            // 背景更为深邃，突显发光晶体
            LinearGradient(
                colors: [
                    Color(hue: 0.65, saturation: 0.20, brightness: 0.15),
                    Color(hue: 0.70, saturation: 0.25, brightness: 0.05),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("Echo Imprint")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.8))

                    Spacer()

                    Button(action: { showLibrary = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 15))
                            Text("\(specimenStore.specimens.count)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Main organism
                SoundOrganismView(
                    amplitude: audioRecorder.currentAmplitude,
                    frequency: audioRecorder.currentFrequency,
                    rhythm: audioRecorder.currentRhythm,
                    size: 340,
                    onGrowthUpdate: { growth in
                        audioRecorder.lastGrowth = growth
                    }
                )
                .transaction { $0.animation = nil }

                Spacer()

                // Bottom controls
                VStack(spacing: 20) {
                    Text(audioRecorder.isRecording ? "Crystallizing sound..." : "Tap to capture a memory")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.6))
                        .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)

                    // Record button - Redesigned
                    Button(action: {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                        } else {
                            Task { await audioRecorder.startRecording() }
                        }
                    }) {
                        ZStack {
                            if audioRecorder.isRecording {
                                // 优雅的白色脉冲光晕，去掉红线
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                    .shadow(color: Color.white.opacity(0.1), radius: 20)
                                    .scaleEffect(1.0 + (pulseScale - 1.0) * 1.5)

                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                    .scaleEffect(pulseScale)

                                // 录音中：方形停止键
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 24, height: 24)
                            } else {
                                // 默认状态
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 4)

                                Image(systemName: "mic.fill")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.9))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark) // 强制深色模式以配合发光晶体
        .onChange(of: audioRecorder.isRecording) { isRecording in
            if isRecording {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
                if wasRecording {
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
        .sheet(isPresented: $showLibrary) {
            LibraryView(specimenStore: specimenStore)
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.06
        }
    }

    private func stopPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.4)) {
            pulseScale = 1.0
        }
    }
}

// LibraryView 保持不变
struct LibraryView: View {
    @ObservedObject var specimenStore: SpecimenStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if specimenStore.specimens.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "waveform.circle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(.systemGray3))
                        Text("No sound memories yet")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.systemGray))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(specimenStore.specimens) { specimen in
                                SpecimenCardView(
                                    specimen: specimen,
                                    onRename: { newName in
                                        specimenStore.rename(specimen: specimen, to: newName)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Sound Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
            }
        }
    }
}
