import SwiftUI

struct SoundGridView: View {
    let sounds: [SoundItem]
    let activeSoundID: SoundItem.ID?
    let onSoundTapped: (SoundItem) -> Void

    private let columns = 7
    private let rows = 12
    private let gap: CGFloat = 8

    /// Fixed corner radius for non-square tiles (hero, wide strips, etc.).
    private let rectangleCornerRadius: CGFloat = 48

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let cellSize = (width - gap * CGFloat(columns - 1)) / CGFloat(columns)
            let gridHeight = cellSize * CGFloat(rows) + gap * CGFloat(rows - 1)

            ZStack(alignment: .topLeading) {
                ForEach(sounds) { sound in
                    tile(for: sound, cellSize: cellSize)
                }
            }
            .frame(width: width, height: gridHeight, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(Self.widthToHeightRatio(gap: gap), contentMode: .fit)
    }

    @ViewBuilder
    private func tile(for sound: SoundItem, cellSize: CGFloat) -> some View {
        let placement = sound.gridPlacement
        let tileWidth = cellSize * CGFloat(placement.columnSpan) + gap * CGFloat(placement.columnSpan - 1)
        let tileHeight = cellSize * CGFloat(placement.rowSpan) + gap * CGFloat(placement.rowSpan - 1)
        let x = CGFloat(placement.column) * (cellSize + gap) + tileWidth / 2
        let y = CGFloat(placement.row) * (cellSize + gap) + tileHeight / 2

        SoundTileButton(
            sound: sound,
            isActive: activeSoundID == sound.id,
            shape: tileShape(for: placement)
        ) {
            onSoundTapped(sound)
        }
        .frame(width: tileWidth, height: tileHeight)
        .position(x: x, y: y)
    }

    /// Equal column/row span on a square-cell grid produces a square tile → circle.
    private func tileShape(for placement: SoundGridPlacement) -> SoundTileButton.ShapeStyle {
        if placement.columnSpan == placement.rowSpan {
            return .circle
        }
        return .roundedRectangle(cornerRadius: rectangleCornerRadius)
    }

    /// Width-to-height ratio for square cells with uniform gaps (reference width 360pt).
    static func widthToHeightRatio(gap: CGFloat, referenceWidth: CGFloat = 360) -> CGFloat {
        let height = (12 * referenceWidth + 5 * gap) / 7
        return referenceWidth / height
    }
}

struct SoundTileButton: View {
    enum ShapeStyle {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
    }

    let sound: SoundItem
    let isActive: Bool
    var shape: ShapeStyle = .roundedRectangle(cornerRadius: 48)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                tileBackground
                    .overlay(tileBorder)

                Text(sound.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadow(color: .black.opacity(0.35), radius: 10, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(sound.name))
    }

    @ViewBuilder
    private var tileBackground: some View {
        switch shape {
        case .circle:
            Circle()
                .fill(SoundTileGradients.gradient(for: sound.visualStyle))
        case .roundedRectangle(let cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(SoundTileGradients.gradient(for: sound.visualStyle))
        }
    }

    @ViewBuilder
    private var tileBorder: some View {
        switch shape {
        case .circle:
            Circle()
                .stroke(
                    isActive ? Color(red: 0.18, green: 0.85, blue: 0.32).opacity(0.9) : Color.white.opacity(0.2),
                    lineWidth: isActive ? 3 : 1
                )
        case .roundedRectangle(let cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    isActive ? Color(red: 0.18, green: 0.85, blue: 0.32).opacity(0.9) : Color.white.opacity(0.2),
                    lineWidth: isActive ? 3 : 1
                )
        }
    }
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
