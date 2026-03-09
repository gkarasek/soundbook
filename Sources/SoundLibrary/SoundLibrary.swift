import Foundation

/// Manages the collection of available sounds and effects
struct Sound: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: SoundCategory
    let fileName: String
    let duration: TimeInterval
    
    enum SoundCategory: String, Codable {
        case ambient
        case effect
        case nature
        case urban
        case custom
    }
}

class SoundLibrary {
    static let shared = SoundLibrary()
    
    private(set) var sounds: [Sound] = []
    
    init() {
        loadDefaultSounds()
    }
    
    /// Load default sound library
    private func loadDefaultSounds() {
        let defaultSounds: [Sound] = [
            Sound(id: UUID(), name: "Forest Ambiance", category: .ambient, fileName: "forest_ambiance.mp3", duration: 300),
            Sound(id: UUID(), name: "City Traffic", category: .urban, fileName: "city_traffic.mp3", duration: 120),
            Sound(id: UUID(), name: "Rain", category: .nature, fileName: "rain.mp3", duration: 180),
            Sound(id: UUID(), name: "Thunder", category: .effect, fileName: "thunder.mp3", duration: 5),
            Sound(id: UUID(), name: "Door Creak", category: .effect, fileName: "door_creak.mp3", duration: 2),
        ]
        sounds = defaultSounds
    }
    
    /// Search sounds by name
    /// - Parameter query: Search query string
    /// - Returns: Array of matching sounds
    func search(query: String) -> [Sound] {
        sounds.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    /// Get sounds by category
    /// - Parameter category: The sound category to filter by
    /// - Returns: Array of sounds in the specified category
    func soundsByCategory(_ category: Sound.SoundCategory) -> [Sound] {
        sounds.filter { $0.category == category }
    }
    
    /// Add a custom sound to the library
    /// - Parameters:
    ///   - name: Display name of the sound
    ///   - fileName: File name in the bundle
    ///   - duration: Duration of the sound in seconds
    func addCustomSound(name: String, fileName: String, duration: TimeInterval) {
        let newSound = Sound(id: UUID(), name: name, category: .custom, fileName: fileName, duration: duration)
        sounds.append(newSound)
    }
}