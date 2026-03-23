import AVFoundation

/// Handles all audio playback and synchronization for soundbook
class AudioEngine {
    static let shared = AudioEngine()

    private let audioSession = AVAudioSession.sharedInstance()
    private var currentPlayer: AVAudioPlayer?
    private var currentURL: URL?

    init() {
        configureAudioSession()
    }

    /// Configure audio session for optimal playback
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    /// Play a single sound and stop any currently active one.
    /// Returns false when the file cannot be played.
    @discardableResult
    func playExclusive(from soundURL: URL) -> Bool {
        stopCurrent()

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            currentPlayer = audioPlayer
            currentURL = soundURL
            return true
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
            currentPlayer = nil
            currentURL = nil
            return false
        }
    }

    /// Compatibility shim for previous call sites.
    @discardableResult
    func playSoundEffect(from soundURL: URL, atTime: TimeInterval = 0) -> Bool {
        _ = atTime // Reserved for future scheduling behavior.
        return playExclusive(from: soundURL)
    }

    func stopCurrent() {
        currentPlayer?.stop()
        currentPlayer = nil
        currentURL = nil
    }

    func stopAllAudio() {
        stopCurrent()
    }

    func pauseAllAudio() {
        currentPlayer?.pause()
    }

    func resumeAllAudio() {
        currentPlayer?.play()
    }

    func isPlayingCurrentSound() -> Bool {
        currentPlayer?.isPlaying == true
    }

    func isPlaying(soundURL: URL) -> Bool {
        guard let currentURL else { return false }
        return currentURL == soundURL && isPlayingCurrentSound()
    }
}
}