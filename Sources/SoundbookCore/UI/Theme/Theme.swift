import SwiftUI

enum AppColors {
    static let offWhite = Color(red: 241 / 255, green: 241 / 255, blue: 241 / 255)
    static let splashTop = Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
    static let holdOverlayTop = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
}

enum AppAnimations {
    static let dockSelection = Animation.spring(response: 0.38, dampingFraction: 0.86)
    static let splashIntro = Animation.spring(response: 0.95, dampingFraction: 0.82)
    static let splashExit = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.88)
    static let galleryReveal = Animation.timingCurve(0.16, 1, 0.3, 1, duration: 1.05)
    static let galleryEntrance = Animation.spring(response: 0.62, dampingFraction: 0.84)
}

enum SoundTileGradients {
    static func gradient(for style: SoundTileVisualStyle) -> LinearGradient {
        switch style {
        case .aurora:
            return LinearGradient(colors: [Color(red: 0.52, green: 0.68, blue: 0.78), Color(red: 0.14, green: 0.26, blue: 0.40)], startPoint: .top, endPoint: .bottom)
        case .nightForest:
            return LinearGradient(colors: [Color(red: 0.16, green: 0.45, blue: 0.37), Color(red: 0.03, green: 0.16, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .moonMist:
            return LinearGradient(colors: [Color(red: 0.26, green: 0.41, blue: 0.46), Color(red: 0.08, green: 0.15, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .leaves:
            return LinearGradient(colors: [Color(red: 0.42, green: 0.20, blue: 0.14), Color(red: 0.15, green: 0.08, blue: 0.07)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .canyon:
            return LinearGradient(colors: [Color(red: 0.33, green: 0.21, blue: 0.16), Color(red: 0.09, green: 0.12, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fog:
            return LinearGradient(colors: [Color(red: 0.18, green: 0.32, blue: 0.38), Color(red: 0.05, green: 0.09, blue: 0.14)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .skyline:
            return LinearGradient(colors: [Color(red: 0.17, green: 0.23, blue: 0.30), Color(red: 0.07, green: 0.09, blue: 0.13)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .alley:
            return LinearGradient(colors: [Color(red: 0.24, green: 0.19, blue: 0.26), Color(red: 0.08, green: 0.09, blue: 0.13)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .siren:
            return LinearGradient(colors: [Color(red: 0.41, green: 0.07, blue: 0.11), Color(red: 0.14, green: 0.05, blue: 0.13)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .asphalt:
            return LinearGradient(colors: [Color(red: 0.17, green: 0.19, blue: 0.24), Color(red: 0.07, green: 0.08, blue: 0.11)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .station:
            return LinearGradient(colors: [Color(red: 0.35, green: 0.18, blue: 0.11), Color(red: 0.14, green: 0.06, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rooftop:
            return LinearGradient(colors: [Color(red: 0.20, green: 0.27, blue: 0.35), Color(red: 0.09, green: 0.11, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .crossing:
            return LinearGradient(colors: [Color(red: 0.22, green: 0.20, blue: 0.16), Color(red: 0.09, green: 0.08, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .bridge:
            return LinearGradient(colors: [Color(red: 0.12, green: 0.27, blue: 0.34), Color(red: 0.06, green: 0.09, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .plaza:
            return LinearGradient(colors: [Color(red: 0.30, green: 0.22, blue: 0.20), Color(red: 0.11, green: 0.08, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .tunnel:
            return LinearGradient(colors: [Color(red: 0.16, green: 0.16, blue: 0.18), Color(red: 0.06, green: 0.07, blue: 0.09)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    static func dockGradient(for style: SoundTileVisualStyle) -> LinearGradient {
        switch style {
        case .nightForest:
            return LinearGradient(colors: [Color(red: 0.18, green: 0.50, blue: 0.48), Color(red: 0.06, green: 0.20, blue: 0.26)], startPoint: .top, endPoint: .bottom)
        case .skyline:
            return LinearGradient(colors: [Color(red: 0.36, green: 0.25, blue: 0.45), Color(red: 0.17, green: 0.13, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .bridge:
            return LinearGradient(colors: [Color(red: 0.20, green: 0.45, blue: 0.52), Color(red: 0.08, green: 0.18, blue: 0.28)], startPoint: .top, endPoint: .bottom)
        case .canyon:
            return LinearGradient(colors: [Color(red: 0.74, green: 0.45, blue: 0.24), Color(red: 0.45, green: 0.28, blue: 0.14)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return gradient(for: style)
        }
    }
}
