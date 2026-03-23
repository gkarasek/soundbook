import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = SoundboardViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 132), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(viewModel.visibleSounds) { sound in
                            SoundTileButton(
                                sound: sound,
                                isActive: viewModel.activeSoundID == sound.id
                            ) {
                                viewModel.onSoundTapped(sound)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }

                LibrarySelectorBar(
                    libraries: viewModel.libraries,
                    selectedLibraryID: viewModel.selectedLibraryID
                ) { library in
                    viewModel.selectLibrary(library)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }
}

private struct SoundTileButton: View {
    let sound: SoundItem
    let isActive: Bool
    let action: () -> Void

    private var tileHeight: CGFloat {
        switch sound.tileSize {
        case .hero:
            return 220
        case .large:
            return 170
        case .medium:
            return 135
        case .small:
            return 110
        case .wide:
            return 115
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(gradient(for: sound.visualStyle))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(
                                isActive ? Color.green.opacity(0.9) : Color.white.opacity(0.08),
                                lineWidth: isActive ? 3 : 1
                            )
                    )

                Text(sound.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.white.opacity(0.85))
                    .padding(12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: tileHeight)
            .shadow(color: .black.opacity(0.35), radius: 10, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(sound.name))
    }

    private func gradient(for style: SoundTileVisualStyle) -> LinearGradient {
        switch style {
        case .aurora:
            return LinearGradient(colors: [Color(red: 0.16, green: 0.45, blue: 0.37), Color(red: 0.03, green: 0.16, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .nightForest:
            return LinearGradient(colors: [Color(red: 0.04, green: 0.16, blue: 0.24), Color(red: 0.10, green: 0.29, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
}

private struct LibrarySelectorBar: View {
    let libraries: [SoundLibraryModel]
    let selectedLibraryID: SoundLibraryModel.ID?
    let onSelectLibrary: (SoundLibraryModel) -> Void

    var body: some View {
        HStack(spacing: 14) {
            ForEach(libraries) { library in
                let isSelected = selectedLibraryID == library.id
                Button {
                    onSelectLibrary(library)
                } label: {
                    Circle()
                        .fill(gradient(for: library.iconStyle))
                        .frame(width: isSelected ? 66 : 54, height: isSelected ? 66 : 54)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.green.opacity(0.9) : Color.white.opacity(0.14),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(library.name))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func gradient(for style: SoundTileVisualStyle) -> LinearGradient {
        switch style {
        case .nightForest:
            return LinearGradient(colors: [Color(red: 0.14, green: 0.36, blue: 0.30), Color(red: 0.05, green: 0.16, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .skyline:
            return LinearGradient(colors: [Color(red: 0.36, green: 0.25, blue: 0.45), Color(red: 0.17, green: 0.13, blue: 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(red: 0.24, green: 0.25, blue: 0.28), Color(red: 0.13, green: 0.13, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview {
    ContentView()
}
