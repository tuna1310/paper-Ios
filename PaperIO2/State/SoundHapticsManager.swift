import AVFoundation
import UIKit

/// Synthesizes crisp arcade sound effects and triggers tactile haptics without external audio assets.
final class SoundHapticsManager {
    static let shared = SoundHapticsManager()

    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let format: AVAudioFormat?
    private var isEngineConfigured = false

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notifier = UINotificationFeedbackGenerator()

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        configureAudioIfPossible()
    }

    private func configureAudioIfPossible() {
        guard let format = format else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
            try engine.start()
            isEngineConfigured = true
        } catch {
            isEngineConfigured = false
        }
    }

    // MARK: - Haptics

    func tapHaptic() {
        guard hapticsEnabled else { return }
        lightImpact.impactOccurred()
    }

    func captureHaptic() {
        guard hapticsEnabled else { return }
        mediumImpact.impactOccurred()
    }

    func killHaptic() {
        guard hapticsEnabled else { return }
        heavyImpact.impactOccurred()
    }

    func successHaptic() {
        guard hapticsEnabled else { return }
        notifier.notificationOccurred(.success)
    }

    func failureHaptic() {
        guard hapticsEnabled else { return }
        notifier.notificationOccurred(.error)
    }

    // MARK: - Procedural Sounds

    func playTap() {
        tapHaptic()
        playTone(startFreq: 680, endFreq: 880, duration: 0.055, gain: 0.14)
    }

    func playSwipeCard() {
        tapHaptic()
        playTone(startFreq: 520, endFreq: 740, duration: 0.05, gain: 0.12)
    }

    func playCapture(areaRatio: Double) {
        captureHaptic()
        let pitchBoost = min(320.0, areaRatio * 2400.0)
        playTone(startFreq: 440 + pitchBoost * 0.4, endFreq: 740 + pitchBoost, duration: 0.13, gain: 0.18)
    }

    func playKill() {
        killHaptic()
        playTone(startFreq: 960, endFreq: 480, duration: 0.14, gain: 0.22)
    }

    func playPowerUp() {
        successHaptic()
        playTone(startFreq: 520, endFreq: 1180, duration: 0.18, gain: 0.20)
    }

    func playGameOver() {
        failureHaptic()
        playTone(startFreq: 380, endFreq: 160, duration: 0.28, gain: 0.22)
    }

    func playReward() {
        successHaptic()
        playTone(startFreq: 587, endFreq: 1046, duration: 0.22, gain: 0.20)
    }

    private func playTone(startFreq: Double, endFreq: Double, duration: Double, gain: Float) {
        guard soundEnabled, isEngineConfigured, let format = format else { return }
        if !engine.isRunning {
            try? engine.start()
        }
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let samples = buffer.floatChannelData?[0] else { return }
        var phase: Double = 0
        let count = Int(frameCount)
        for i in 0..<count {
            let t = Double(i) / Double(max(1, count))
            let freq = startFreq + (endFreq - startFreq) * t
            phase += (2.0 * Double.pi * freq) / sampleRate
            let envelope = Float(sin(Double.pi * min(1.0, t))) * Float(1.0 - t * 0.35)
            samples[i] = Float(sin(phase)) * gain * envelope
        }

        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
}
