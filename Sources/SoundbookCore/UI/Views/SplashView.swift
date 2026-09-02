import SwiftUI

struct SplashView: View {
    let logoReveal: CGFloat
    let dismissProgress: CGFloat

    private let markSize: CGFloat = 111.333

    var body: some View {
        ZStack {
            splashBackground

            SoundbookLogoMark(
                reveal: logoReveal,
                dismissProgress: dismissProgress
            )
            .frame(width: markSize, height: markSize)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Soundbook"))
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

struct SoundbookLogoMark: View {
    let reveal: CGFloat
    let dismissProgress: CGFloat

    var body: some View {
        let entrance = min(1, max(0, reveal))
        let scale = (0.9 + entrance * 0.1) * (1 + dismissProgress * 0.12)

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
                        .stroke(AppColors.offWhite.opacity(0.1), lineWidth: 1)
                )

            Image("Logo")
                .resizable()
                .scaledToFit()
                .padding(24)
        }
        .scaleEffect(scale)
        .opacity(Double(entrance * (1 - dismissProgress)))
    }
}

#Preview {
    SplashView(logoReveal: 1, dismissProgress: 0)
}
