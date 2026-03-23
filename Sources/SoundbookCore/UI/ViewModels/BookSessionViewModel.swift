import Foundation
import SwiftUI

@MainActor
final class BookSessionViewModel: ObservableObject {
    @Published var sessions: [BookSession] = []

    func createSession(title: String, bookTitle: String, audioURL: URL? = nil) {
        let newSession = BookSession(
            id: UUID(),
            title: title,
            bookTitle: bookTitle,
            audioURL: audioURL,
            soundMappings: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        sessions.append(newSession)
    }

    func deleteSession(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
    }
}

@MainActor
final class SoundboardViewModel: ObservableObject {
    @Published private(set) var libraries: [SoundLibraryModel]
    @Published var selectedLibraryID: SoundLibraryModel.ID?
    @Published var activeSoundID: SoundItem.ID?

    private let audioEngine: AudioEngine

    init(
        soundLibrary: SoundLibrary = .shared,
        audioEngine: AudioEngine = .shared
    ) {
        self.libraries = soundLibrary.libraries
        self.selectedLibraryID = soundLibrary.libraries.first?.id
        self.audioEngine = audioEngine
    }

    var selectedLibrary: SoundLibraryModel? {
        guard let selectedLibraryID else { return libraries.first }
        return libraries.first(where: { $0.id == selectedLibraryID }) ?? libraries.first
    }

    var visibleSounds: [SoundItem] {
        selectedLibrary?.sounds ?? []
    }

    func selectLibrary(_ library: SoundLibraryModel) {
        selectedLibraryID = library.id
        stopActiveSound()
    }

    func onSoundTapped(_ sound: SoundItem) {
        if activeSoundID == sound.id {
            stopActiveSound()
            return
        }

        guard let soundURL = resolveAudioURL(for: sound.fileName) else {
            audioEngine.stopCurrent()
            activeSoundID = nil
            return
        }

        let didStart = audioEngine.playExclusive(from: soundURL)
        activeSoundID = didStart ? sound.id : nil
    }

    func stopActiveSound() {
        audioEngine.stopCurrent()
        activeSoundID = nil
    }

    private func resolveAudioURL(for fileName: String) -> URL? {
        if fileName.contains("/") {
            let fileURL = URL(fileURLWithPath: fileName)
            return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
        }

        let nsFileName = fileName as NSString
        let base = nsFileName.deletingPathExtension
        let ext = nsFileName.pathExtension.isEmpty ? nil : nsFileName.pathExtension
        return Bundle.main.url(forResource: base, withExtension: ext)
    }
}
