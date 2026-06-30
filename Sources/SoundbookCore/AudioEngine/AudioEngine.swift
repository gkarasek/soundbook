import AVFoundation

/// Handles all audio playback and synchronization for soundbook
class AudioEngine {
    static let shared = AudioEngine()

    static let effectVolume: Float = 1.0
    /// Background ambience sits 40% below foreground effects.
    static let backgroundVolume: Float = 0.6
    static let fadeDuration: TimeInterval = 1.0

    private let audioSession = AVAudioSession.sharedInstance()
    private var effectPlayer: AVAudioPlayer?
    private var effectURL: URL?
    private var backgroundPlayer: AVAudioPlayer?
    private var backgroundURL: URL?
    private var effectFadeTimer: Timer?

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

    /// Play a single looping sound effect and stop any currently active foreground effect.
    /// Returns false when the file cannot be played.
    @discardableResult
    func playExclusive(from soundURL: URL) -> Bool {
        stopCurrentImmediately()

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            effectPlayer = audioPlayer
            effectURL = soundURL
            fadeEffectVolume(to: Self.effectVolume, duration: Self.fadeDuration)
            return true
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
            effectPlayer = nil
            effectURL = nil
            return false
        }
    }

    /// Loop gallery ambience underneath foreground effects.
    @discardableResult
    func playBackground(from soundURL: URL) -> Bool {
        if backgroundURL == soundURL, backgroundPlayer?.isPlaying == true {
            return true
        }

        stopBackground()

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = Self.backgroundVolume
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            backgroundPlayer = audioPlayer
            backgroundURL = soundURL
            return true
        } catch {
            print("Error playing background sound: \(error.localizedDescription)")
            backgroundPlayer = nil
            backgroundURL = nil
            return false
        }
    }

    /// Compatibility shim for previous call sites.
    @discardableResult
    func playSoundEffect(from soundURL: URL, atTime: TimeInterval = 0) -> Bool {
        _ = atTime // Reserved for future scheduling behavior.
        return playExclusive(from: soundURL)
    }

    func fadeOutAndStopCurrent() {
        guard effectPlayer != nil else { return }

        fadeEffectVolume(to: 0, duration: Self.fadeDuration) { [weak self] in
            self?.stopCurrentImmediately()
        }
    }

    func stopCurrentImmediately() {
        cancelEffectFade()
        effectPlayer?.stop()
        effectPlayer = nil
        effectURL = nil
    }

    func stopCurrent() {
        fadeOutAndStopCurrent()
    }

    func stopBackground() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
        backgroundURL = nil
    }

    func stopAllAudio() {
        stopCurrentImmediately()
        stopBackground()
    }

    func pauseAllAudio() {
        cancelEffectFade()
        effectPlayer?.pause()
        backgroundPlayer?.pause()
    }

    func resumeAllAudio() {
        effectPlayer?.play()
        backgroundPlayer?.play()
    }

    func isPlayingCurrentSound() -> Bool {
        effectPlayer?.isPlaying == true
    }

    func isPlaying(soundURL: URL) -> Bool {
        guard let effectURL else { return false }
        return effectURL == soundURL && isPlayingCurrentSound()
    }

    private func cancelEffectFade() {
        effectFadeTimer?.invalidate()
        effectFadeTimer = nil
    }

    private func fadeEffectVolume(
        to target: Float,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        cancelEffectFade()

        guard let player = effectPlayer else {
            completion?()
            return
        }

        let startVolume = player.volume
        let startTime = Date()

        effectFadeTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            guard let self, let player = self.effectPlayer else {
                timer.invalidate()
                completion?()
                return
            }

            let progress = min(1.0, Date().timeIntervalSince(startTime) / duration)
            player.volume = startVolume + Float(progress) * (target - startVolume)

            if progress >= 1.0 {
                timer.invalidate()
                self.effectFadeTimer = nil
                completion?()
            }
        }
    }
}
