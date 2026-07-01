import Combine
import SwiftUI

struct GalleryDockView: View {
    let libraries: [SoundLibraryModel]
    let selectedLibraryID: SoundLibraryModel.ID?
    let isBackgroundPlaying: Bool
    let onSelectLibrary: (SoundLibraryModel) -> Void

    private let pillHeight: CGFloat = 80
    private let dockCornerRadius: CGFloat = 96
    private let dockPadding: CGFloat = 8
    private let dockTrackID = "dockTrack"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(libraries) { library in
                        let isSelected = selectedLibraryID == library.id
                        let isPlaying = isSelected && isBackgroundPlaying
                        Button {
                            withAnimation(AppAnimations.dockSelection) {
                                onSelectLibrary(library)
                            }
                        } label: {
                            GalleryDockPill(
                                library: library,
                                isSelected: isSelected,
                                isPlaying: isPlaying,
                                height: pillHeight
                            )
                        }
                        .buttonStyle(.plain)
                        .id(library.id)
                        .accessibilityLabel(Text(library.name))
                        .accessibilityHint(
                            Text(
                                isSelected
                                    ? (isPlaying
                                        ? "Double tap to turn off background ambience"
                                        : "Double tap to turn on background ambience")
                                    : ""
                            )
                        )
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
                .padding(dockPadding)
                .id(dockTrackID)
            }
            .onChange(of: selectedLibraryID) { newValue in
                guard let newValue else { return }
                scrollToLibrary(newValue, proxy: proxy, animated: true)
            }
        }
        .background(dockBackground)
        .clipShape(RoundedRectangle(cornerRadius: dockCornerRadius, style: .continuous))
    }

    private var dockBackground: some View {
        RoundedRectangle(cornerRadius: dockCornerRadius, style: .continuous)
            .fill(AppColors.offWhite.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: dockCornerRadius, style: .continuous)
                    .stroke(AppColors.offWhite.opacity(0.2), lineWidth: 1)
            )
    }

    private func scrollToLibrary(
        _ id: SoundLibraryModel.ID,
        proxy: ScrollViewProxy,
        animated: Bool
    ) {
        guard let index = libraries.firstIndex(where: { $0.id == id }) else { return }

        let scroll: () -> Void
        if index == 0 {
            scroll = { proxy.scrollTo(dockTrackID, anchor: .leading) }
        } else if index == libraries.count - 1 {
            scroll = { proxy.scrollTo(dockTrackID, anchor: .trailing) }
        } else {
            scroll = { proxy.scrollTo(id, anchor: .center) }
        }

        if animated {
            withAnimation(AppAnimations.dockSelection) {
                scroll()
            }
            guard index == 0 || index == libraries.count - 1 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                withAnimation(AppAnimations.dockSelection) {
                    scroll()
                }
            }
        } else {
            scroll()
        }
    }
}

private struct GalleryDockPill: View {
    let library: SoundLibraryModel
    let isSelected: Bool
    let isPlaying: Bool
    let height: CGFloat

    @State private var showAura = false
    @State private var auraOpacity: Double = 0

    private let selectedWidth: CGFloat = 240
    private let idleWidth: CGFloat = 160

    private var idleColor: Color { Color(red: 189 / 255, green: 115 / 255, blue: 61 / 255) }
    private var selectedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 46 / 255, green: 128 / 255, blue: 122 / 255),
                Color(red: 15 / 255, green: 51 / 255, blue: 66 / 255),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var borderColor: Color {
        isSelected
            ? Color(red: 46 / 255, green: 217 / 255, blue: 82 / 255).opacity(0.8)
            : AppColors.offWhite.opacity(0.4)
    }

    var body: some View {
        ZStack {
            Capsule()
                .fill(idleColor)

            Capsule()
                .fill(selectedGradient)
                .opacity(isSelected ? 1 : 0)

            Capsule()
                .fill(SoundTileGradients.dockGradient(for: library.iconStyle))
                .padding(10)
                .opacity(isSelected ? 0.35 : 0)

            if showAura {
                GalleryDockPlayingAura()
                    .opacity(auraOpacity)
            }
        }
        .frame(width: isSelected ? selectedWidth : idleWidth, height: height)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .animation(AppAnimations.dockSelection, value: isSelected)
        .onAppear {
            syncAura(to: isPlaying, animated: false)
        }
        .onChange(of: isPlaying) { playing in
            syncAura(to: playing, animated: true)
        }
    }

    private func syncAura(to playing: Bool, animated: Bool) {
        let fade = AppAnimations.backgroundFade

        if playing {
            showAura = true
            if animated {
                withAnimation(fade) {
                    auraOpacity = 1
                }
            } else {
                auraOpacity = 1
            }
            return
        }

        if animated {
            withAnimation(fade) {
                auraOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + AppAnimations.backgroundFadeDuration) {
                if !isPlaying {
                    showAura = false
                }
            }
        } else {
            auraOpacity = 0
            showAura = false
        }
    }
}

private struct GalleryDockPlayingAura: View {
    @State private var time: TimeInterval = 0

    private let tick = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()
    private let blobCount = 8
    private let borderBandWidth: CGFloat = 32
    private let maskFeatherBlur: CGFloat = 5
    private let auraBlur: CGFloat = 7

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let radiusX = max(width * 0.5 - borderBandWidth * 0.25, 1)
            let radiusY = max(height * 0.5 - borderBandWidth * 0.25, 1)
            let baseSize = min(width, height)

            ZStack {
                auraField(baseSize: baseSize, radiusX: radiusX, radiusY: radiusY, blur: auraBlur * 1.5, sizeScale: 1.18, opacity: 0.55)
                auraField(baseSize: baseSize, radiusX: radiusX, radiusY: radiusY, blur: auraBlur, sizeScale: 1, opacity: 1)
            }
            .frame(width: width, height: height)
            .brightness(0.08)
            .mask(
                Capsule()
                    .strokeBorder(Color.white, lineWidth: borderBandWidth)
                    .blur(radius: maskFeatherBlur)
            )
        }
        .compositingGroup()
        .blendMode(.lighten)
        .onReceive(tick) { date in
            time = date.timeIntervalSinceReferenceDate
        }
    }

    private func auraField(
        baseSize: CGFloat,
        radiusX: CGFloat,
        radiusY: CGFloat,
        blur: CGFloat,
        sizeScale: CGFloat,
        opacity: Double
    ) -> some View {
        ZStack {
            ForEach(0..<blobCount, id: \.self) { index in
                organicBlob(
                    index: index,
                    baseSize: baseSize * sizeScale,
                    radiusX: radiusX,
                    radiusY: radiusY
                )
                .opacity(opacity)
            }
        }
        .blur(radius: blur)
    }

    private func organicBlob(
        index: Int,
        baseSize: CGFloat,
        radiusX: CGFloat,
        radiusY: CGFloat
    ) -> some View {
        let phase = Double(index) * 1.73
        let orbitAngle = time * 0.52
            + phase * 1.9
            + sin(time * 0.62 + phase) * 0.38
        let radialWobbleX = 1 + 0.09 * sin(time * 0.88 + phase * 1.4)
        let radialWobbleY = 1 + 0.09 * cos(time * 1.05 + phase * 1.1)
        let breathX = 0.68 + 0.44 * sin(time * 2.15 + phase * 1.35)
        let breathY = 0.68 + 0.44 * cos(time * 1.82 + phase * 1.6)
        let diameter = baseSize * (0.30 + 0.10 * sin(time * 1.45 + phase * 2.2))
        let spin = time * 38 + phase * 47
        let color = GalleryDockAuraPalette.colors[index % GalleryDockAuraPalette.colors.count]

        return OrganicAuraBlob(
            color: color,
            diameter: diameter,
            scaleX: breathX,
            scaleY: breathY,
            spin: spin
        )
        .offset(
            x: CGFloat(cos(orbitAngle)) * radiusX * radialWobbleX,
            y: CGFloat(sin(orbitAngle)) * radiusY * radialWobbleY
        )
    }
}

private struct OrganicAuraBlob: View {
    let color: Color
    let diameter: CGFloat
    let scaleX: CGFloat
    let scaleY: CGFloat
    let spin: Double

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color,
                        color.opacity(0.92),
                        color.opacity(0.55),
                        color.opacity(0.18),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * 0.58
                )
            )
            .frame(width: diameter, height: diameter)
            .scaleEffect(x: scaleX, y: scaleY)
            .rotationEffect(.degrees(spin))
    }
}

private enum GalleryDockAuraPalette {
    static let colors: [Color] = [
        Color(red: 46 / 255, green: 217 / 255, blue: 82 / 255),
        Color(red: 46 / 255, green: 217 / 255, blue: 146 / 255),
        Color(red: 119 / 255, green: 245 / 255, blue: 56 / 255),
        Color(red: 248 / 255, green: 255 / 255, blue: 44 / 255),
        Color(red: 90 / 255, green: 255 / 255, blue: 120 / 255),
        Color(red: 46 / 255, green: 217 / 255, blue: 146 / 255),
        Color(red: 180 / 255, green: 255 / 255, blue: 70 / 255),
        Color(red: 46 / 255, green: 217 / 255, blue: 82 / 255),
    ]
}

#Preview {
    GalleryDockView(
        libraries: SoundLibrary.shared.libraries,
        selectedLibraryID: SoundLibrary.shared.libraries.first?.id,
        isBackgroundPlaying: true,
        onSelectLibrary: { _ in }
    )
    .padding()
    .background(Color.black)
}
