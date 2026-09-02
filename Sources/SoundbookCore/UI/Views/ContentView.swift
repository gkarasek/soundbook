import SwiftUI

public struct ContentView: View {
    @ObservedObject private var viewModel: SoundboardViewModel
    private let entranceProgress: CGFloat

    init(
        viewModel: SoundboardViewModel,
        entranceProgress: CGFloat = 1
    ) {
        self.viewModel = viewModel
        self.entranceProgress = entranceProgress
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.07),
                    Color.black,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                contentArea
                navigationArea
            }
        }
    }

    private var contentArea: some View {
        VStack {
            Spacer(minLength: 0)
            SoundGridView(
                sounds: viewModel.visibleSounds,
                entranceProgress: entranceProgress,
                onSoundPressBegan: viewModel.onSoundPressBegan,
                onSoundPressEnded: viewModel.onSoundPressEnded
            )
            .padding(.horizontal, 24)
            .id(viewModel.selectedLibraryID)
            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .bottom)))
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: 0.28), value: viewModel.selectedLibraryID)
    }

    private var navigationArea: some View {
        GalleryDockView(
            libraries: viewModel.libraries,
            selectedLibraryID: viewModel.selectedLibraryID,
            isBackgroundPlaying: viewModel.isBackgroundPlaying,
            onSelectLibrary: viewModel.selectLibrary
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .offset(y: (1 - entranceProgress) * 48)
        .opacity(Double(min(1, entranceProgress * 1.35)))
    }
}

#Preview {
    ContentView(viewModel: SoundboardViewModel())
}
