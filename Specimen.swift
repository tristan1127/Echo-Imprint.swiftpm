import Foundation

struct Specimen: Identifiable, Codable {
    let id: UUID
    var name: String
    let createdAt: Date
    let amplitude: Float
    let frequency: Float
    let rhythm: Float
    let growth: Float
    let audioFileName: String?
    let imageFileName: String? // 🌟 必须加上这一行

    // 计算音频文件的本地路径
    var audioURL: URL? {
        guard let fileName = audioFileName else { return nil }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }
    
    // 🌟 必须加上这一行：计算截图图片的本地路径
    var imageURL: URL? {
        guard let fileName = imageFileName else { return nil }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: createdAt)
    }
}
