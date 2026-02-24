import Foundation

@MainActor
final class SpecimenStore: ObservableObject {
    @Published var specimens: [Specimen] = []
    private let saveKey = "echo_specimens"

    init() { load() }

    func save(amplitude: Float, frequency: Float, rhythm: Float, growth: Float, audioURL: URL?) {
        // Copy audio file to permanent location with specimen ID
        var audioFileName: String? = nil
        if let sourceURL = audioURL {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let ext = sourceURL.pathExtension
            let fileName = "specimen_\(UUID().uuidString).\(ext)"
            let destURL = docs.appendingPathComponent(fileName)
            try? FileManager.default.copyItem(at: sourceURL, to: destURL)
            audioFileName = fileName
        }

        let specimen = Specimen(
            id: UUID(),
            name: "Sound Memory",
            createdAt: Date(),
            amplitude: amplitude,
            frequency: frequency,
            rhythm: rhythm,
            growth: growth,
            audioFileName: audioFileName
        )
        specimens.insert(specimen, at: 0)
        persist()
    }

    func rename(specimen: Specimen, to newName: String) {
        if let idx = specimens.firstIndex(where: { $0.id == specimen.id }) {
            specimens[idx].name = newName
            persist()
        }
    }

    func delete(at offsets: IndexSet) {
        // Also delete audio files
        for idx in offsets {
            if let url = specimens[idx].audioURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
        specimens.remove(atOffsets: offsets)
        persist()
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
