import Foundation
import SwiftUI

@MainActor
final class SoundboardViewModel: ObservableObject {
    @Published private(set) var libraries: [SoundLibraryModel]
    @Published var selectedLibraryID: SoundLibraryModel.ID?
    @Published private(set) var isBackgroundPlaying = false

    private let audioEngine: AudioEngine
    private var gallerySessionStarted = false

    init(
        soundLibrary: SoundLibrary = .shared,
        audioEngine: AudioEngine = .shared
    ) {
        self.libraries = soundLibrary.libraries
        self.selectedLibraryID = soundLibrary.libraries.first?.id
        self.audioEngine = audioEngine
    }

    func beginGallerySession() {
        guard !gallerySessionStarted else { return }
        gallerySessionStarted = true
    }

    var selectedLibrary: SoundLibraryModel? {
        guard let selectedLibraryID else { return libraries.first }
        return libraries.first(where: { $0.id == selectedLibraryID }) ?? libraries.first
    }

    var visibleSounds: [SoundItem] {
        (selectedLibrary?.sounds ?? []).sorted { lhs, rhs in
            if lhs.gridPlacement.row != rhs.gridPlacement.row {
                return lhs.gridPlacement.row < rhs.gridPlacement.row
            }
            return lhs.gridPlacement.column < rhs.gridPlacement.column
        }
    }

    func selectLibrary(_ library: SoundLibraryModel) {
        if selectedLibraryID == library.id {
            toggleBackgroundAudio()
            return
        }

        selectedLibraryID = library.id
        stopActiveSound()
        isBackgroundPlaying = true
        startBackground(for: library)
    }

    func onSoundPressBegan(_ sound: SoundItem) {
        guard let soundURL = resolveAudioURL(for: sound.fileName) else {
            audioEngine.stopCurrentImmediately()
            return
        }

        _ = audioEngine.playExclusive(from: soundURL)
    }

    func onSoundPressEnded() {
        audioEngine.fadeOutAndStopCurrent()
    }

    func stopActiveSound() {
        audioEngine.fadeOutAndStopCurrent()
    }

    private func toggleBackgroundAudio() {
        if isBackgroundPlaying {
            isBackgroundPlaying = false
            audioEngine.fadeOutAndStopBackground()
            return
        }

        guard let library = selectedLibrary else { return }
        isBackgroundPlaying = true
        startBackground(for: library)
    }

    private func startBackground(for library: SoundLibraryModel) {
        guard let fileName = library.backgroundFileName,
              let soundURL = resolveAudioURL(for: fileName) else {
            isBackgroundPlaying = false
            audioEngine.fadeOutAndStopBackground()
            return
        }

        _ = audioEngine.playBackground(from: soundURL)
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
