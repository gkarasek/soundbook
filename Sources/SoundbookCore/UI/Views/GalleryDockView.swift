import SwiftUI

struct GalleryDockView: View {
    let libraries: [SoundLibraryModel]
    let selectedLibraryID: SoundLibraryModel.ID?
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
                        Button {
                            withAnimation(AppAnimations.dockSelection) {
                                onSelectLibrary(library)
                            }
                        } label: {
                            GalleryDockPill(
                                library: library,
                                isSelected: isSelected,
                                height: pillHeight
                            )
                        }
                        .buttonStyle(.plain)
                        .id(library.id)
                        .accessibilityLabel(Text(library.name))
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
    let height: CGFloat

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
        }
        .frame(width: isSelected ? selectedWidth : idleWidth, height: height)
        .overlay(
            Capsule()
                .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .animation(AppAnimations.dockSelection, value: isSelected)
    }
}

#Preview {
    GalleryDockView(
        libraries: SoundLibrary.shared.libraries,
        selectedLibraryID: SoundLibrary.shared.libraries.first?.id,
        onSelectLibrary: { _ in }
    )
    .padding()
    .background(Color.black)
}
