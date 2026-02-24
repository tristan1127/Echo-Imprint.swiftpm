import Foundation

struct Specimen: Identifiable, Codable {
    let id: UUID
    var name: String
    let createdAt: Date
    let amplitude: Float
    let frequency: Float
    let rhythm: Float
    let growth: Float
    let audioFileName: String?  // stores filename in Documents dir

    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: createdAt)
    }

    var audioURL: URL? {
        guard let fileName = audioFileName else { return nil }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }
}
