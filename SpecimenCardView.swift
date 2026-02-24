import SwiftUI
import AVFoundation

struct SpecimenCardView: View {
    let specimen: Specimen
    let onRename: (String) -> Void

    @State private var isPlaying = false
    @State private var isRenaming = false
    @State private var editName = ""
    @State private var player: AVAudioPlayer?

    var body: some View {
        HStack(spacing: 16) {

            // Preview — full-size organism scaled down via scaleEffect
            // This shows the real frozen shape, not a tiny canvas
            ZStack {
                SoundOrganismView(
                    amplitude: specimen.amplitude,
                    frequency: specimen.frequency,
                    rhythm: specimen.rhythm,
                    size: 320,
                    isFrozen: true,
                    frozenGrowth: specimen.growth
                )
                .scaleEffect(0.28)          // scale 320 → ~90pt visual
                .frame(width: 90, height: 90)
                .clipped()
            }
            .frame(width: 90, height: 90)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .allowsHitTesting(false)

            // Info
            VStack(alignment: .leading, spacing: 6) {
                if isRenaming {
                    TextField("Name", text: $editName, onCommit: {
                        let trimmed = editName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty { onRename(trimmed) }
                        isRenaming = false
                    })
                    .font(.system(size: 15, weight: .semibold))
                    .textFieldStyle(.plain)
                    .onAppear { editName = specimen.name }
                } else {
                    Text(specimen.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .onTapGesture(count: 2) {
                            editName = specimen.name
                            isRenaming = true
                        }
                }

                Text(specimen.timeLabel)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.systemGray))
            }

            Spacer()

            // Playback button
            VStack(spacing: 8) {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(specimen.audioURL != nil ? Color(.systemBlue) : Color(.systemGray3))
                }
                .disabled(specimen.audioURL == nil)

                // Rename button
                Button(action: {
                    editName = specimen.name
                    isRenaming = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private func togglePlayback() {
        if isPlaying {
            player?.stop()
            player = nil
            isPlaying = false
            return
        }

        guard let url = specimen.audioURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            let p = try AVAudioPlayer(contentsOf: url)
            player = p
            p.play()
            isPlaying = true

            // Auto-reset when done
            Task {
                try? await Task.sleep(nanoseconds: UInt64(p.duration * 1_000_000_000) + 200_000_000)
                await MainActor.run {
                    isPlaying = false
                    player = nil
                }
            }
        } catch {
            print("Playback error: \(error)")
        }
    }
}
