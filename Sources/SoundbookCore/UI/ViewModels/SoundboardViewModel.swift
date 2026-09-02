import Foundation
import SwiftUI

@MainActor
final class SoundboardViewModel: ObservableObject {
    @Published private(set) var libraries: [SoundLibraryModel]
    @Published var selectedLibraryID: SoundLibraryModel.ID?
    @Published private(set) var isBackgroundPlaying = false

    private let audioEngine: AudioEngine
    private var gallerySessionStarted = false
    private var isHolding = false
    private var tapAutoStopTimer: Timer?
    private var holdDetectTimer: Timer?

    /// A single tap plays for this long (fade in + sustain + fade out), then stops.
    private static let tapPlayDuration: TimeInterval = 4
    /// Keeping a finger down longer than this turns the press into a hold that loops until release.
    private static let holdThreshold: TimeInterval = 0.4

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
            cancelPlaybackTimers()
            isHolding = false
            audioEngine.stopCurrentImmediately()
            return
        }

        cancelPlaybackTimers()
        isHolding = false
        _ = audioEngine.playExclusive(from: soundURL)

        // Default assumption: this is a tap. Schedule the fade-out so total playback lasts tapPlayDuration.
        // This does not depend on the release event firing, so a tap always stops on its own.
        let fadeOutStart = max(0, Self.tapPlayDuration - AudioEngine.fadeDuration)
        tapAutoStopTimer = Timer.scheduledTimer(withTimeInterval: fadeOutStart, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.finishPlayback() }
        }

        // If the finger is still down after the threshold, upgrade to a hold that loops until release.
        holdDetectTimer = Timer.scheduledTimer(withTimeInterval: Self.holdThreshold, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.isHolding = true
                self.tapAutoStopTimer?.invalidate()
                self.tapAutoStopTimer = nil
            }
        }
    }

    func onSoundPressEnded() {
        holdDetectTimer?.invalidate()
        holdDetectTimer = nil

        // A hold stops as soon as the finger lifts; a tap keeps playing until its auto-stop timer fires.
        if isHolding {
            finishPlayback()
        }
    }

    func stopActiveSound() {
        finishPlayback()
    }

    private func finishPlayback() {
        cancelPlaybackTimers()
        isHolding = false
        audioEngine.fadeOutAndStopCurrent()
    }

    private func cancelPlaybackTimers() {
        tapAutoStopTimer?.invalidate()
        tapAutoStopTimer = nil
        holdDetectTimer?.invalidate()
        holdDetectTimer = nil
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
