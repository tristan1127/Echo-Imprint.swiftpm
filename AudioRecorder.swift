import AVFoundation
import Foundation

// MARK: - Recording Implementation Summary
//
// CURRENT IMPLEMENTATION:
// - Uses AVAudioEngine (inputNode tap + AVAudioFile) for Mac Catalyst compatibility
// - On iOS: First tries AVAudioRecorder to produce .m4a files; falls back to engine if needed
// - On Mac Catalyst: Uses AVAudioEngine and saves as .caf (AVAudioSession can be unreliable)
// - When recording stops: File is saved in Documents directory and URL is printed to console
// - Playback: Uses AVAudioPlayer with the most recent recording URL

@MainActor
final class AudioRecorder: ObservableObject {

    @Published var isRecording: Bool = false
    @Published var currentAmplitude: Float = 0.0
    @Published var currentFrequency: Float = 0.0
    @Published var currentRhythm: Float = 0.0
    @Published var lastRecordingURL: URL?
    @Published var isPlaying: Bool = false

    nonisolated(unsafe) private var audioEngine: AVAudioEngine?
    nonisolated(unsafe) private var audioFile: AVAudioFile?
    private var recordingURL: URL?
    private var simulationTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
#if os(iOS)
    private var audioRecorder: AVAudioRecorder?
#endif

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
        guard granted else {
            print("❌ Microphone permission denied")
            return false
        }

#if os(iOS)
        // Try AVAudioRecorder first for .m4a files on iOS
        if await startRecordingM4A() {
            print("✅ Recording started (AVAudioRecorder .m4a)")
            isRecording = true
            return true
        }
        print("⚠️ AVAudioRecorder failed, falling back to AVAudioEngine")
#endif

        // Fallback to AVAudioEngine (works on Mac Catalyst and as iOS fallback)
        let realSuccess = await startRealRecording()
        if realSuccess {
            print("✅ Recording started (AVAudioEngine .caf)")
            isRecording = true
            return true
        }

        // Fallback for Mac testing (simulation mode)
        print("⚠️ Using simulation mode (no real audio)")
        startSimulation()
        isRecording = true
        return true
    }

#if os(iOS)
    /// Uses AVAudioRecorder to create a .m4a file in Documents directory.
    private func startRecordingM4A() async -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "echo_\(Int(Date().timeIntervalSince1970)).m4a"
        let url = docs.appendingPathComponent(fileName)
        recordingURL = url

        do {
            // Configure audio session for recording
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("❌ AVAudioSession setup failed: \(error.localizedDescription)")
            return false
        }

        // Settings for AAC encoding (.m4a)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            audioRecorder = recorder
            
            let started = recorder.record()
            if started {
                startMeteringTimer()
                return true
            } else {
                print("❌ AVAudioRecorder.record() returned false")
                return false
            }
        } catch {
            print("❌ AVAudioRecorder creation failed: \(error.localizedDescription)")
            return false
        }
    }

    private func startMeteringTimer() {
        simulationTimer?.invalidate()
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let rec = self.audioRecorder else { return }
                rec.updateMeters()
                let power = rec.averagePower(forChannel: 0)
                // Convert dB to normalized 0-1 range
                let normalized = max(0.0, min(1.0, (power + 60) / 60))
                self.currentAmplitude = Float(normalized)
                // Simulate frequency and rhythm for visualization
                self.currentFrequency = (self.currentFrequency + 0.01).truncatingRemainder(dividingBy: 1.0)
                self.currentRhythm = (self.currentRhythm + 0.02).truncatingRemainder(dividingBy: 1.0)
            }
        }
        RunLoop.main.add(simulationTimer!, forMode: .common)
    }
#endif

    /// Uses AVAudioEngine + AVAudioFile (writes .caf in Documents). Used on Mac Catalyst or as fallback.
    private func startRealRecording() async -> Bool {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("echo_\(Int(Date().timeIntervalSince1970)).caf")
        recordingURL = url

        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)

        guard format.sampleRate > 0 && format.channelCount > 0 else {
            print("❌ Invalid input format: sampleRate=\(format.sampleRate), channels=\(format.channelCount)")
            return false
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
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
            print("❌ AVAudioEngine recording failed: \(error.localizedDescription)")
            audioEngine = nil
            audioFile = nil
            return false
        }
    }

    private func startSimulation() {
        var tick: Float = 0
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) {
            [weak self] _ in
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

#if os(iOS)
        // Stop AVAudioRecorder if it was used
        if let rec = audioRecorder, rec.isRecording {
            rec.stop()
            audioRecorder = nil
            
            if let url = recordingURL {
                lastRecordingURL = url
                print("✅ Recording saved (.m4a): \(url.path)")
            }
            
            // Deactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("⚠️ Failed to deactivate audio session: \(error.localizedDescription)")
            }
        }
#endif

        // Stop AVAudioEngine if it was used
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        
        if let url = recordingURL, audioFile != nil {
            lastRecordingURL = url
            print("✅ Recording saved (.caf): \(url.path)")
        }
        
        audioFile = nil
        audioEngine = nil
        currentAmplitude = 0
        currentFrequency = 0
        currentRhythm = 0
        isRecording = false
        recordingURL = nil
    }
    
    /// Play back the most recent recording. Uses AVAudioPlayer; no third-party libraries.
    func playLastRecording() {
        guard let url = lastRecordingURL else {
            print("❌ No recording to play. Record something first.")
            return
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Recording file not found: \(url.path)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            player.prepareToPlay()
            player.play()
            isPlaying = true
            print("▶️ Playing: \(url.path)")
            
            // Reset isPlaying when done
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(player.duration * 1_000_000_000))
                self.isPlaying = false
                print("⏹️ Playback finished")
            }
        } catch {
            print("❌ Playback failed: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    nonisolated deinit {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
    }
}
