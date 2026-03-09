import SwiftUI

class BookSessionViewModel: ObservableObject {
    @Published var sessions: [BookSession] = []
    @Published var currentSession: BookSession?

    func createSession(book: Book) {
        let newSession = BookSession(book: book)
        sessions.append(newSession)
        currentSession = newSession
    }

    func updateSession(session: BookSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
    }

    func deleteSession(session: BookSession) {
        sessions.removeAll { $0.id == session.id }
        if currentSession?.id == session.id {
            currentSession = nil
        }
    }

    func startSession(session: BookSession) {
        currentSession = session
    }

    func endSession() {
        currentSession = nil
    }
}

struct BookSession {
    var id = UUID()
    var book: Book
    var startTime: Date = Date()
    var endTime: Date?
}

struct Book {
    var title: String
    var author: String
    var description: String
}