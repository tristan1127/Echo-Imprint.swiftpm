import AVFoundation
import Foundation

@MainActor
final class AudioRecorder: ObservableObject {

    @Published var isRecording: Bool = false
    @Published var currentAmplitude: Float = 0.0
    @Published var currentFrequency: Float = 0.0
    @Published var currentRhythm: Float = 0.0

    nonisolated(unsafe) private var audioEngine: AVAudioEngine?
    nonisolated(unsafe) private var audioFile: AVAudioFile?
    private var recordingURL: URL?
    private var simulationTimer: Timer?

    func requestMicrophonePermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized { return true }
        if status == .denied || status == .restricted { return false }
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() async -> Bool {
        let granted = await requestMicrophonePermission()
        guard granted else { return false }

        let realSuccess = await startRealRecording()
        if realSuccess {
            isRecording = true
            return true
        }

        // Fallback for Mac testing
        print("⚠️ Using simulation mode")
        startSimulation()
        isRecording = true
        return true
    }

    private func startRealRecording() async -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("echo_\(Int(Date().timeIntervalSince1970)).caf")
        recordingURL = url

        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)

        guard format.sampleRate > 0 && format.channelCount > 0 else { return false }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]

        do {
            let file = try AVAudioFile(forWriting: url, settings: settings)
            audioFile = file
            audioEngine = engine

            input.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak file] buffer, _ in
                guard let f = file else { return }
                try? f.write(from: buffer)
                if let channelData = buffer.floatChannelData?[0] {
                    let frameLength = Int(buffer.frameLength)
                    var sum: Float = 0
                    for i in 0..<frameLength { sum += abs(channelData[i]) }
                    let amplitude = sum / Float(frameLength)
                    Task { @MainActor [weak self] in
                        self?.currentAmplitude = min(amplitude * 10, 1.0)
                    }
                }
            }

            engine.prepare()
            try engine.start()
            return true
        } catch {
            audioEngine = nil
            audioFile = nil
            return false
        }
    }

    private func startSimulation() {
        var tick: Float = 0
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                tick += 0.1
                self?.currentAmplitude = (sin(tick * 1.3) + 1) / 2 * 0.8
                self?.currentFrequency = (sin(tick * 0.7) + 1) / 2
                self?.currentRhythm = (sin(tick * 2.1) + 1) / 2
            }
        }
    }

    func stopRecording() {
        simulationTimer?.invalidate()
        simulationTimer = nil
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioFile = nil
        audioEngine = nil
        currentAmplitude = 0
        currentFrequency = 0
        currentRhythm = 0
        isRecording = false
        recordingURL = nil
    }

    nonisolated deinit {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
    }
}

