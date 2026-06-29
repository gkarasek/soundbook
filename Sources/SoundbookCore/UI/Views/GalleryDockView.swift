import SwiftUI

struct GalleryDockView: View {
    let libraries: [SoundLibraryModel]
    let selectedLibraryID: SoundLibraryModel.ID?
    let onSelectLibrary: (SoundLibraryModel) -> Void

    private let pillHeight: CGFloat = 80
    private let dockCornerRadius: CGFloat = 96
    private let selectionAnimation = Animation.spring(response: 0.38, dampingFraction: 0.82)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(libraries) { library in
                        let isSelected = selectedLibraryID == library.id
                        Button {
                            withAnimation(selectionAnimation) {
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
                .padding(8)
            }
            .onAppear {
                if let selectedLibraryID {
                    scrollToLibrary(selectedLibraryID, proxy: proxy, animated: false)
                }
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
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: dockCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
            )
    }

    private func scrollToLibrary(
        _ id: SoundLibraryModel.ID,
        proxy: ScrollViewProxy,
        animated: Bool
    ) {
        let anchor = scrollAnchor(for: id)
        if animated {
            withAnimation(selectionAnimation) {
                proxy.scrollTo(id, anchor: anchor)
            }
        } else {
            proxy.scrollTo(id, anchor: anchor)
        }
    }

    private func scrollAnchor(for id: SoundLibraryModel.ID) -> UnitPoint {
        guard let index = libraries.firstIndex(where: { $0.id == id }) else {
            return .center
        }
        if index == 0 { return UnitPoint(x: 0, y: 0.5) }
        if index == libraries.count - 1 { return UnitPoint(x: 1, y: 0.5) }
        return .center
    }
}

private struct GalleryDockPill: View {
    let library: SoundLibraryModel
    let isSelected: Bool
    let height: CGFloat

    private let selectedWidth: CGFloat = 240
    private let idleWidth: CGFloat = 160
    private var pillCornerRadius: CGFloat { height / 2 }

    var body: some View {
        ZStack {
            pillFill
            if isSelected {
                selectedAccent
            }
        }
        .frame(width: isSelected ? selectedWidth : idleWidth, height: height)
        .overlay(pillBorder)
        .clipShape(RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous))
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isSelected)
    }

    @ViewBuilder
    private var pillFill: some View {
        if isSelected {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.50, blue: 0.48),
                    Color(red: 0.06, green: 0.20, blue: 0.26),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color(red: 0.74, green: 0.45, blue: 0.24)
        }
    }

    private var selectedAccent: some View {
        RoundedRectangle(cornerRadius: pillCornerRadius - 8, style: .continuous)
            .fill(SoundTileGradients.dockGradient(for: library.iconStyle))
            .padding(10)
            .opacity(0.35)
    }

    private var pillBorder: some View {
        RoundedRectangle(cornerRadius: pillCornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
    }

    private var borderColor: Color {
        isSelected
            ? Color(red: 0.18, green: 0.85, blue: 0.32).opacity(0.8)
            : Color.white.opacity(0.2)
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
