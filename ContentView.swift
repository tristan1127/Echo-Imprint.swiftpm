import AVFoundation
import SwiftUI

struct ContentView: View {

    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var specimenStore = SpecimenStore()
    
    // 使用 AppStorage 保存用户的主题偏好
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var wasRecording: Bool = false
    @State private var showLibrary: Bool = false

    var body: some View {
        ZStack {
            // 适配深浅模式的渐变背景
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hue: 0.65, saturation: 0.20, brightness: 0.15),
                    Color(hue: 0.70, saturation: 0.25, brightness: 0.05),
                ] : [
                    Color(hue: 0.60, saturation: 0.05, brightness: 0.96),
                    Color(hue: 0.65, saturation: 0.10, brightness: 0.88),
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
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.8) : Color.black.opacity(0.7))

                    Spacer()
                    
                    // 日夜间模式切换按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isDarkMode.toggle()
                        }
                    }) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 16))
                            .foregroundColor(isDarkMode ? .yellow : .orange)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 8)

                    Button(action: { showLibrary = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 15))
                            Text("\(specimenStore.specimens.count)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.8))
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
                        .foregroundColor(isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.5))
                        .animation(.easeInOut(duration: 0.3), value: audioRecorder.isRecording)

                    // 动态自适应的录音按钮
                    let themeColor = isDarkMode ? Color.white : Color.black

                    Button(action: {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                        } else {
                            Task { await audioRecorder.startRecording() }
                        }
                    }) {
                        ZStack {
                            if audioRecorder.isRecording {
                                // 优雅的脉冲光晕，根据主题变色
                                Circle()
                                    .fill(themeColor.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(themeColor.opacity(0.2), lineWidth: 1))
                                    .shadow(color: themeColor.opacity(0.1), radius: 20)
                                    .scaleEffect(1.0 + (pulseScale - 1.0) * 1.5)

                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                    .overlay(Circle().stroke(themeColor.opacity(0.4), lineWidth: 1))
                                    .scaleEffect(pulseScale)

                                // 录音中：方形停止键
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(themeColor.opacity(0.9))
                                    .frame(width: 24, height: 24)
                            } else {
                                // 默认状态
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                    .overlay(Circle().stroke(themeColor.opacity(0.3), lineWidth: 1))
                                    .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.05), radius: 16, x: 0, y: 4)

                                Image(systemName: "mic.fill")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(themeColor.opacity(0.9))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light) // 动态覆盖系统主题
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
                .preferredColorScheme(isDarkMode ? .dark : .light) // 确保弹出窗口也遵循主题
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

// 包含了滑动删除的 LibraryView
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
                    // 使用 List 替代 ScrollView，以获取原生的滑动删除功能
                    List {
                        ForEach(specimenStore.specimens) { specimen in
                            SpecimenCardView(
                                specimen: specimen,
                                onRename: { newName in
                                    specimenStore.rename(specimen: specimen, to: newName)
                                }
                            )
                            // 保持卡片样式，去除列表默认的线和背景
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                        .onDelete(perform: { indexSet in
                            withAnimation {
                                specimenStore.delete(at: indexSet)
                            }
                        })
                    }
                    .listStyle(.plain)
                    .padding(.top, 8)
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
