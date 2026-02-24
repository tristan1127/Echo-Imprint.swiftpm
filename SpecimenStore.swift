import Foundation

@MainActor
final class SpecimenStore: ObservableObject {
    @Published var specimens: [Specimen] = []

    private let saveKey = "echo_specimens"

    init() { load() }

    func save(amplitude: Float, frequency: Float, rhythm: Float, growth: Float) {
        let specimen = Specimen(
            id: UUID(),
            createdAt: Date(),
            amplitude: amplitude,
            frequency: frequency,
            rhythm: rhythm,
            growth: growth
        )
        specimens.insert(specimen, at: 0)
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

    func delete(at offsets: IndexSet) {
        specimens.remove(atOffsets: offsets)
        persist()
    }
}

