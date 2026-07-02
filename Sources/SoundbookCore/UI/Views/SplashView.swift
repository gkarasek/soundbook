import Combine
import SwiftUI

struct SplashView: View {
    let logoReveal: CGFloat
    let dismissProgress: CGFloat

    @State private var auroraPhase: CGFloat = 0
    @State private var breathePhase: CGFloat = 0

    private let markSize: CGFloat = 120
    private let auroraTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            splashBackground

            SplashAuroraBackground(
                reveal: logoReveal * (1 - dismissProgress * 0.35),
                phase: auroraPhase
            )

            SoundbookLogoMark(
                reveal: logoReveal,
                dismissProgress: dismissProgress,
                breathePhase: breathePhase
            )
            .frame(width: markSize, height: markSize)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Soundbook"))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                breathePhase = 1
            }
        }
        .onReceive(auroraTimer) { _ in
            auroraPhase += 0.035
        }
    }

    private var splashBackground: some View {
        LinearGradient(
            stops: [
                .init(color: AppColors.splashTop, location: 0),
                .init(color: AppColors.splashTop, location: 0.2),
                .init(color: .black, location: 0.938),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct SplashAuroraBackground: View {
    let reveal: CGFloat
    let phase: CGFloat

    private let blobs: [AuroraBlob] = [
        AuroraBlob(x: 0.18, anchorY: 0.02, widthRatio: 0.95, heightRatio: 0.42, color: AppColors.auroraGreen, seed: 0.0, riseSpeed: 1.0),
        AuroraBlob(x: 0.42, anchorY: 0.00, widthRatio: 1.15, heightRatio: 0.48, color: AppColors.auroraTeal, seed: 1.4, riseSpeed: 1.15),
        AuroraBlob(x: 0.68, anchorY: 0.04, widthRatio: 1.05, heightRatio: 0.44, color: AppColors.auroraGreen, seed: 2.8, riseSpeed: 0.95),
        AuroraBlob(x: 0.88, anchorY: 0.01, widthRatio: 0.88, heightRatio: 0.38, color: AppColors.auroraLime, seed: 0.7, riseSpeed: 1.25),
        AuroraBlob(x: 0.05, anchorY: 0.06, widthRatio: 0.82, heightRatio: 0.36, color: AppColors.auroraLime, seed: 3.5, riseSpeed: 1.1),
        AuroraBlob(x: 0.30, anchorY: 0.10, widthRatio: 0.78, heightRatio: 0.34, color: AppColors.auroraYellow, seed: 2.1, riseSpeed: 1.3),
        AuroraBlob(x: 0.55, anchorY: 0.08, widthRatio: 0.92, heightRatio: 0.40, color: AppColors.auroraYellow, seed: 4.2, riseSpeed: 1.05),
        AuroraBlob(x: 0.78, anchorY: 0.12, widthRatio: 0.74, heightRatio: 0.32, color: AppColors.auroraTeal, seed: 1.9, riseSpeed: 1.2),
        AuroraBlob(x: 0.12, anchorY: 0.14, widthRatio: 0.70, heightRatio: 0.30, color: AppColors.auroraTeal, seed: 5.0, riseSpeed: 0.9),
        AuroraBlob(x: 0.50, anchorY: 0.16, widthRatio: 0.86, heightRatio: 0.28, color: AppColors.auroraLime, seed: 3.1, riseSpeed: 1.35),
        AuroraBlob(x: 0.92, anchorY: 0.10, widthRatio: 0.68, heightRatio: 0.30, color: AppColors.auroraGreen, seed: 0.3, riseSpeed: 1.0),
        AuroraBlob(x: 0.36, anchorY: 0.18, widthRatio: 0.64, heightRatio: 0.26, color: AppColors.auroraYellow, seed: 4.8, riseSpeed: 1.15),
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let bottomWashHeight = size.height * 0.52

            ZStack {
                LinearGradient(
                    colors: [
                        Color.clear,
                        AppColors.auroraGreen.opacity(0.08),
                        AppColors.auroraLime.opacity(0.16),
                        AppColors.auroraYellow.opacity(0.10),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: bottomWashHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .opacity(Double(reveal * 0.9))

                ForEach(blobs) { blob in
                    flameBlob(blob, in: size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func flameBlob(_ blob: AuroraBlob, in size: CGSize) -> some View {
        let t = phase * blob.riseSpeed + blob.seed
        let flicker = sin(t * 2.4) * 0.5 + 0.5
        let rise = (sin(t * 1.35 - .pi / 2) * 0.5 + 0.5)
        let riseLift = rise * size.height * 0.14
        let wobbleX = sin(t * 1.8) * size.width * 0.04
            + sin(t * 3.1 + blob.seed) * size.width * 0.025
        let stretchY = 0.88 + flicker * 0.28 + rise * 0.18
        let stretchX = 0.94 + sin(t * 2.0 + blob.seed) * 0.12
        let opacity = (0.42 + flicker * 0.28 + rise * 0.18) * Double(reveal)

        Ellipse()
            .fill(blob.color)
            .frame(
                width: size.width * blob.widthRatio * stretchX,
                height: size.height * blob.heightRatio * stretchY
            )
            .blur(radius: size.width * 0.09)
            .blendMode(.screen)
            .opacity(opacity)
            .position(
                x: size.width * blob.x + wobbleX,
                y: size.height + size.height * blob.anchorY - riseLift
            )
    }
}

private struct AuroraBlob: Identifiable {
    let id = UUID()
    let x: CGFloat
    let anchorY: CGFloat
    let widthRatio: CGFloat
    let heightRatio: CGFloat
    let color: Color
    let seed: CGFloat
    let riseSpeed: CGFloat
}

struct SoundbookLogoMark: View {
    let reveal: CGFloat
    let dismissProgress: CGFloat
    let breathePhase: CGFloat

    var body: some View {
        let entrance = eased(reveal, delay: 0.04)
        let ringEntrance = eased(reveal, delay: 0)
        let glyphEntrance = eased(reveal, delay: 0.12)
        let breathe = 1 + breathePhase * 0.018
        let exitScale = 1 + dismissProgress * 0.14
        let scale = (0.78 + ringEntrance * 0.22) * breathe * exitScale

        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.offWhite.opacity(0.05),
                            AppColors.offWhite.opacity(0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.offWhite.opacity(0.1 * Double(ringEntrance)), lineWidth: 1)
                )
                .scaleEffect(0.92 + ringEntrance * 0.08)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .padding(24)
                .scaleEffect(0.88 + glyphEntrance * 0.12)
                .opacity(Double(glyphEntrance))
        }
        .scaleEffect(scale)
        .opacity(Double(entrance * (1 - dismissProgress)))
    }

    private func eased(_ progress: CGFloat, delay: CGFloat) -> CGFloat {
        let shifted = (progress - delay) / max(0.001, 1 - delay)
        return min(1, max(0, shifted))
    }
}

#Preview {
    SplashView(logoReveal: 1, dismissProgress: 0)
}
