import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var specimenStore = SpecimenStore()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @State private var showLibrary: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var dragVelocity: CGFloat = 0

    var body: some View {
        ZStack {
            // 动态背景
            (isDarkMode ? Color.black : Color(white: 0.96)).ignoresSafeArea()
            
            VStack {
                topBar
                Spacer()
                
                // 中央图形
                SoundOrganismView(
                    amplitude: audioRecorder.currentAmplitude,
                    frequency: audioRecorder.currentFrequency,
                    rhythm: audioRecorder.currentRhythm,
                    dragX: audioRecorder.dragFilterX,
                    dragY: audioRecorder.dragFilterY,
                    size: 320
                )
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            dragVelocity = CGFloat(hypot(value.translation.width, value.translation.height))
                            let xNorm = Float(min(abs(value.translation.width) / 160, 1.0))
                            let yNorm = Float(min(abs(value.translation.height) / 160, 1.0))
                            audioRecorder.setDragFilter(x: xNorm, y: yNorm)
                        }
                        .onEnded { value in
                            HapticManager.shared.playImpact()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                dragOffset = .zero
                            }
                            audioRecorder.setDragFilter(x: 0, y: 0)
                        }
                )
                
                Spacer()
                
                // 琉璃红录音键 + 提示文字
                VStack(spacing: 8) {
                    recordingButton
                    Text(audioRecorder.isRecording ? "Recording..." : "Tap to capture a memory")
                        .font(.caption)
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.8) : Color.black.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showLibrary) { libraryView }
    }

    private var topBar: some View {
        HStack {
            Text("Echo Imprint").font(.system(.headline, design: .rounded))
            Spacer()
            Button(action: { isDarkMode.toggle() }) {
                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                    .frame(width: 20, height: 20)
                    .padding(9)
                    .background(
                        Circle()
                            .fill(
                                Color.white.opacity(isDarkMode ? 0.16 : 0.32)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        (isDarkMode ? Color.white : Color.black).opacity(0.10),
                                        lineWidth: 0.8
                                    )
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
            
            Button(action: { showLibrary = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(specimenStore.specimens.count)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            Color.white.opacity(isDarkMode ? 0.18 : 0.34)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    (isDarkMode ? Color.white : Color.black).opacity(0.08),
                                    lineWidth: 0.8
                                )
                        )
                )
                .foregroundColor(isDarkMode ? .white : .black)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sound Library, \(specimenStore.specimens.count) \(specimenStore.specimens.count == 1 ? "memory" : "memories") saved")
            .accessibilityHint("Double tap to open your saved sound memories")
        }.padding()
    }

    private var recordingButton: some View {
        Button(action: {
            HapticManager.shared.playImpact() // 震动
            
            if audioRecorder.isRecording {
                // 停止瞬间截图
                let snapshot = takeSnapshot()
                audioRecorder.stopRecording()
                // 保存数据和照片
                specimenStore.save(
                    amplitude: audioRecorder.currentAmplitude,
                    frequency: audioRecorder.currentFrequency,
                    rhythm: audioRecorder.currentRhythm,
                    growth: audioRecorder.lastGrowth,
                    audioURL: audioRecorder.lastRecordingURL,
                    snapshot: snapshot
                )
            } else {
                Task { await audioRecorder.startRecording() }
            }
        }) {
            ZStack {
                // 1. 呼吸起伏的光晕（仅录音时）
                if audioRecorder.isRecording {
                    Circle()
                        .fill(Color.red.opacity(isDarkMode ? 0.35 : 0.22))
                        .frame(width: 92, height: 92)
                        .scaleEffect(pulseScale)
                        .blur(radius: 14)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                pulseScale = 1.25
                            }
                        }
                }

                // 2. iOS 玻璃主体（始终是玻璃，录音时叠加红色渐变）
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.35, blue: 0.35),
                                        Color(red: 0.55, green: 0, blue: 0.1)
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 46
                                )
                            )
                            .opacity(audioRecorder.isRecording ? (isDarkMode ? 1.0 : 0.7) : 0.0)
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                audioRecorder.isRecording
                                ? Color.white.opacity(0.35)
                                : Color.accentColor.opacity(0.7),
                                lineWidth: 1.8
                            )
                    )
                    .shadow(
                        color: audioRecorder.isRecording
                        ? (isDarkMode ? .red.opacity(0.65) : .red.opacity(0.45))
                        : .black.opacity(isDarkMode ? 0.6 : 0.18),
                        radius: audioRecorder.isRecording ? 18 : 10,
                        x: 0,
                        y: audioRecorder.isRecording ? 8 : 4
                    )

                // 3. 图标
                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(audioRecorder.isRecording ? .white : (isDarkMode ? .white : .primary))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(audioRecorder.isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint(audioRecorder.isRecording ? "Double tap to stop and save your sound memory" : "Double tap to begin capturing sound")
    }

    // ✨ 截图核心逻辑
    @MainActor
    private func takeSnapshot() -> UIImage? {
        let renderer = ImageRenderer(content: SoundOrganismView(
            amplitude: audioRecorder.currentAmplitude,
            frequency: audioRecorder.currentFrequency,
            rhythm: audioRecorder.currentRhythm,
            dragX: 0,
            dragY: 0,
            size: 320,
            isFrozen: true,
            frozenGrowth: audioRecorder.lastGrowth
        ))
        renderer.scale = 3.0 // 高清导出
        return renderer.uiImage
    }

    private var libraryView: some View {
        NavigationView {
            List {
                ForEach(specimenStore.specimens) { s in
                    SpecimenCardView(specimen: s, onRename: { specimenStore.rename(specimen: s, to: $0) })
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete {
                    HapticManager.shared.playDelete() // 删除震动
                    specimenStore.delete(at: $0)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        SpecimenCardView.stopAllPlayback()
                        showLibrary = false
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
