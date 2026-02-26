import SwiftUI

@MainActor
class SpecimenStore: ObservableObject {
    @Published var specimens: [Specimen] = []
    private let saveKey = "echo_specimens"

    init() { load() }

    func save(amplitude: Float, frequency: Float, rhythm: Float, growth: Float, audioURL: URL?, snapshot: UIImage?) {
        let id = UUID()
        var audioFileName: String? = nil
        var imageFileName: String? = nil
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // 1. 保存音频
        if let sourceURL = audioURL {
            let name = "audio_\(id.uuidString).caf"
            let dest = docs.appendingPathComponent(name)
            try? FileManager.default.copyItem(at: sourceURL, to: dest)
            audioFileName = name
        }

        // 2. 保存截图照片
        if let image = snapshot, let data = image.pngData() {
            let name = "image_\(id.uuidString).png"
            let dest = docs.appendingPathComponent(name)
            try? data.write(to: dest)
            imageFileName = name
        }

        let specimen = Specimen(
            id: id,
            name: "Sound Memory",
            createdAt: Date(),
            amplitude: amplitude,
            frequency: frequency,
            rhythm: rhythm,
            growth: growth,
            audioFileName: audioFileName,
            imageFileName: imageFileName
        )
        
        specimens.insert(specimen, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let s = specimens[index]
            // 删除本地音频文件
            if let aURL = s.audioURL {
                try? FileManager.default.removeItem(at: aURL)
            }
            // 删除本地图片文件
            if let iURL = s.imageURL {
                try? FileManager.default.removeItem(at: iURL)
            }
        }
        specimens.remove(atOffsets: offsets)
        persist()
    }

    func rename(specimen: Specimen, to newName: String) {
        if let idx = specimens.firstIndex(where: { $0.id == specimen.id }) {
            specimens[idx].name = newName
            persist()
            // 触觉反馈
            HapticManager.shared.playSuccess()
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(specimens) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Specimen].self, from: data) {
            specimens = decoded
        }
    }
}
