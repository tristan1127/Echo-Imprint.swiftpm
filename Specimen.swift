import Foundation
import SwiftUI

struct Specimen: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let amplitude: Float
    let frequency: Float
    let rhythm: Float
    let growth: Float

    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: createdAt)
    }
}

