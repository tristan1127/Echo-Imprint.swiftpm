import SwiftUI
import AVFoundation

struct SpecimenCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let specimen: Specimen
    let onRename: (String) -> Void
    @State private var isPlaying = false
    @State private var isRenaming = false
    @State private var editName = ""
    @State private var player: AVAudioPlayer?

    private static var sharedPlayer: AVAudioPlayer?
    
    static func stopAllPlayback() {
        sharedPlayer?.stop()
        sharedPlayer = nil
    }

    var body: some View {
        HStack(spacing: 16) {
            // 左侧：那一瞬间的真实图案照片
            Group {
                if let url = specimen.imageURL, let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Color.gray.opacity(0.2) // 占位符
                }
            }
            .frame(width: 85, height: 85)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                if isRenaming {
                    TextField("Name", text: $editName, onCommit: {
                        onRename(editName)
                        isRenaming = false
                    })
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 15, weight: .bold))
                } else {
                    Text(specimen.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .accessibilityLabel("\(specimen.name), recorded \(specimen.timeLabel)")
                    Text(specimen.timeLabel)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()

            HStack(spacing: 10) {
                // 播放 / 暂停按钮（玻璃风格）
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(
                                    colorScheme == .dark
                                    ? Color.white.opacity(0.20)
                                    : Color.black.opacity(0.22)
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Stop playback" : "Play \(specimen.name)")
                .accessibilityHint(specimen.audioURL != nil ? "Double tap to \(isPlaying ? "stop" : "play") this recording" : "No audio file available")

                // 铅笔按钮：增加 BorderlessButtonStyle 解决冲突
                Button(action: {
                    editName = specimen.name
                    isRenaming.toggle()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(
                                    colorScheme == .dark
                                    ? Color.white.opacity(0.16)
                                    : Color.black.opacity(0.20)
                                )
                        )
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel("Rename \(specimen.name)")
                .accessibilityHint("Double tap to rename this sound memory")
            }
        }
        .padding(12)
        .padding(.vertical, 4) // 卡片之间增加呼吸间距（尤其是浅色模式）
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func togglePlayback() {
        if isPlaying {
            SpecimenCardView.sharedPlayer?.stop()
            isPlaying = false
            return
        }
        guard let url = specimen.audioURL else { return }
        do {
            SpecimenCardView.sharedPlayer?.stop()
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            SpecimenCardView.sharedPlayer = newPlayer
            player = newPlayer
            newPlayer.play()
            isPlaying = true
            let duration = newPlayer.duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                if SpecimenCardView.sharedPlayer === newPlayer {
                    SpecimenCardView.sharedPlayer?.stop()
                    SpecimenCardView.sharedPlayer = nil
                }
                isPlaying = false
            }
        } catch {
            print("Play error")
            isPlaying = false
        }
    }
}
