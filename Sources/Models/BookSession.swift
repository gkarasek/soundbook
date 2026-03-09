import Foundation

/// Represents a reading session with synchronized sounds
struct BookSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var bookTitle: String
    var audioURL: URL?
    var soundMappings: [SoundMapping] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

/// Maps a sound to play at a specific time in the book
struct SoundMapping: Identifiable, Codable {
    let id: UUID
    let soundID: UUID
    let timestamp: TimeInterval
    let volume: Float = 1.0
    
    enum CodingKeys: String, CodingKey {
        case id
        case soundID
        case timestamp
        case volume
    }
}

class BookSessionManager {
    static let shared = BookSessionManager()
    
    private(set) var sessions: [BookSession] = []
    private let fileManager = FileManager.default
    private lazy var sessionsURL: URL = {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("BookSessions")
    }()
    
    init() {
        createSessionsDirectory()
        loadSessions()
    }
    
    /// Create sessions directory if it doesn't exist
    private func createSessionsDirectory() {
        try? fileManager.createDirectory(at: sessionsURL, withIntermediateDirectories: true)
    }
    
    /// Load all sessions from storage
    private func loadSessions() {
        // Load from disk
    }
    
    /// Save a new session
    /// - Parameter session: The BookSession to save
    func saveSession(_ session: BookSession) {
        sessions.append(session)
        // Persist to disk
    }
    
    /// Delete a session
    /// - Parameter sessionID: The ID of the session to delete
    func deleteSession(withID sessionID: UUID) {
        sessions.removeAll { $0.id == sessionID }
        // Remove from disk
    }
    
    /// Update a session
    /// - Parameter session: The updated BookSession
    func updateSession(_ session: BookSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            // Persist to disk
        }
    }
}