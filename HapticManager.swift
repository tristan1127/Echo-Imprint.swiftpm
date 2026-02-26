import UIKit

@MainActor
final class HapticManager {
    
    static let shared = HapticManager()
    
    // 私有化构造函数，防止外部重复创建
    private init() {}
    
    // 机械按压感（用于录音开始/停止）
    func playImpact() {
        // UIImpactFeedbackGenerator 本身是隔离在 Main Actor 的
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // 成功感（用于重命名或保存）
    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    // 警告感（用于删除）
    func playDelete() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: 0.8)
    }
}
