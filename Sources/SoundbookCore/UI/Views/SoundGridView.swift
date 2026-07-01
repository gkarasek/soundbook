import SwiftUI

struct SoundGridView: View {
    let sounds: [SoundItem]
    let onSoundPressBegan: (SoundItem) -> Void
    let onSoundPressEnded: () -> Void

    private let columns = 7
    private let rows = 12
    private let gap: CGFloat = 8

    /// Fixed corner radius for non-square tiles (hero, wide strips, etc.).
    private let rectangleCornerRadius: CGFloat = 54

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
            shape: tileShape(for: placement),
            onPressBegan: { onSoundPressBegan(sound) },
            onPressEnded: onSoundPressEnded
        )
        .frame(width: tileWidth, height: tileHeight)
        .position(x: x, y: y)
    }

    /// Equal column/row span on a square-cell grid produces a square tile → circle.
    private func tileShape(for placement: SoundGridPlacement) -> TileShape {
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

struct TileShape: InsettableShape {
    enum Kind {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
    }

    let kind: Kind
    var insetAmount: CGFloat = 0

    static let circle = TileShape(kind: .circle)

    static func roundedRectangle(cornerRadius: CGFloat) -> TileShape {
        TileShape(kind: .roundedRectangle(cornerRadius: cornerRadius))
    }

    func path(in rect: CGRect) -> Path {
        switch kind {
        case .circle:
            return Circle().path(in: rect)
        case .roundedRectangle(let cornerRadius):
            return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).path(in: rect)
        }
    }

    func inset(by amount: CGFloat) -> TileShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}

struct SoundTileButton: View {
    let sound: SoundItem
    var shape: TileShape = .roundedRectangle(cornerRadius: 54)
    let onPressBegan: () -> Void
    let onPressEnded: () -> Void

    @State private var isPressed = false

    var body: some View {
        ZStack {
            shape
                .fill(SoundTileGradients.gradient(for: sound.visualStyle))

            shape
                .fill(pressGradient)
                .blendMode(.overlay)

            shape
                .stroke(AppColors.offWhite.opacity(0.2), lineWidth: 1)

            Text(sound.name)
                .font(.caption.weight(.semibold))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(shape)
        .accessibilityLabel(Text(sound.name))
        .pressToPlay(
            onPressBegan: {
                isPressed = true
                onPressBegan()
            },
            onPressEnded: {
                isPressed = false
                onPressEnded()
            }
        )
    }

    private var pressGradient: LinearGradient {
        LinearGradient(
            colors: isPressed
                ? [Color.black.opacity(0.6), Color.clear]
                : [Color.clear, Color.black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private extension View {
    func pressToPlay(onPressBegan: @escaping () -> Void, onPressEnded: @escaping () -> Void) -> some View {
        onLongPressGesture(minimumDuration: 0, pressing: { isPressing in
            if isPressing {
                onPressBegan()
            } else {
                onPressEnded()
            }
        }, perform: {})
        .accessibilityAddTraits(.startsMediaSession)
        .accessibilityHint(Text("Press and hold to play"))
    }
}
