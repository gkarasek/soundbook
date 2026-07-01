import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = SoundboardViewModel()

    public init() {}

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
            onSelectLibrary: viewModel.selectLibrary
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    ContentView()
}
