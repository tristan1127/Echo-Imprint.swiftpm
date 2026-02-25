import UIKit

// 🌟 核心修复 1: 添加 @MainActor，确保这个类所有操作都在主线程执行
// 🌟 核心修复 2: 标记为 final，符合 Sendable 协议要求
@MainActor
final class HapticManager {
    
    // 🌟 核心修复 3: 这里的单例现在是线程安全的，因为它被隔离在 Main Actor
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
