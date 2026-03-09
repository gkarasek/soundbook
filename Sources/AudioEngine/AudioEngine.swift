import AVFoundation

/// Handles all audio playback and synchronization for soundbook
class AudioEngine {
    static let shared = AudioEngine()
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioPlayers: [AVAudioPlayer] = []
    private var currentTime: TimeInterval = 0
    
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
    
    /// Play a sound effect at the specified time
    /// - Parameters:
    ///   - soundURL: URL of the sound file to play
    ///   - atTime: Time offset in seconds when the sound should start
    func playSoundEffect(from soundURL: URL, atTime: TimeInterval = 0) {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayers.append(audioPlayer)
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    /// Stop all current audio playback
    func stopAllAudio() {
        audioPlayers.forEach { $0.stop() }
        audioPlayers.removeAll()
    }
    
    /// Pause all audio playback
    func pauseAllAudio() {
        audioPlayers.forEach { $0.pause() }
    }
    
    /// Resume all paused audio
    func resumeAllAudio() {
        audioPlayers.forEach { $0.play() }
    }
}