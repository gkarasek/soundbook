import SwiftUI
import UIKit

struct NoiseTextureOverlay: View {
    var body: some View {
        Image(uiImage: NoiseTexture.image)
            .resizable(resizingMode: .tile)
            .blendMode(.overlay)
            .opacity(AppColors.noiseOverlayOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

private enum NoiseTexture {
    static let image: UIImage = {
        let dimension = 128
        var pixels = [UInt8](repeating: 0, count: dimension * dimension)

        for index in pixels.indices {
            pixels[index] = UInt8.random(in: 72...184)
        }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else {
            return UIImage()
        }

        guard let cgImage = CGImage(
            width: dimension,
            height: dimension,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: dimension,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage)
    }()
}
