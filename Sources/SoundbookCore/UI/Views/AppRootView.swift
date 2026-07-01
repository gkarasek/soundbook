import SwiftUI

public struct AppRootView: View {
    @StateObject private var viewModel = SoundboardViewModel()
    @State private var logoReveal: CGFloat = 0
    @State private var dismissProgress: CGFloat = 0
    @State private var galleryReveal: CGFloat = 0
    @State private var showSplash = true
    @State private var didStartLaunch = false

    public init() {}

    public var body: some View {
        ZStack {
            ContentView(
                viewModel: viewModel,
                entranceProgress: galleryReveal
            )
            .opacity(Double(galleryReveal))
            .scaleEffect(1.02 - galleryReveal * 0.02)

            if showSplash {
                SplashView(
                    logoReveal: logoReveal,
                    dismissProgress: dismissProgress
                )
                .opacity(Double(1 - dismissProgress))
                .zIndex(1)
            }

            NoiseTextureOverlay()
                .zIndex(2)
        }
        .onAppear(perform: startLaunchSequenceIfNeeded)
    }

    private func startLaunchSequenceIfNeeded() {
        guard !didStartLaunch else { return }
        didStartLaunch = true
        runLaunchSequence()
    }

    private func runLaunchSequence() {
        withAnimation(AppAnimations.splashIntro) {
            logoReveal = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(AppAnimations.splashExit) {
                dismissProgress = 1
                galleryReveal = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            viewModel.beginGallerySession()
            showSplash = false
        }
    }
}

#Preview {
    AppRootView()
}
