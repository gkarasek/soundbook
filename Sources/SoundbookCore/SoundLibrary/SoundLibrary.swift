import Foundation

/// Lightweight visual style key so UI can map to gradients/placeholders.
enum SoundTileVisualStyle: String, Codable {
    case aurora
    case nightForest
    case moonMist
    case leaves
    case canyon
    case fog
    case skyline
    case alley
    case siren
    case asphalt
    case station
    case rooftop
    case crossing
    case bridge
    case plaza
    case tunnel
}

/// Position of a sound tile within the 7×12 interface grid (0-based, matching Figma).
struct SoundGridPlacement: Codable, Hashable {
    let column: Int
    let row: Int
    let columnSpan: Int
    let rowSpan: Int
}

/// One playable sound item shown as a rounded grid button.
struct SoundItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let fileName: String
    let visualStyle: SoundTileVisualStyle
    let gridPlacement: SoundGridPlacement
}

/// A themed group of sounds selectable from the bottom gallery dock.
struct SoundLibraryModel: Identifiable, Codable {
    let id: UUID
    let key: String
    let name: String
    let iconStyle: SoundTileVisualStyle
    let backgroundFileName: String?
    let sounds: [SoundItem]
}

class SoundLibrary {
    static let shared = SoundLibrary()

    private(set) var libraries: [SoundLibraryModel] = []

    init() {
        loadDefaultSounds()
    }

    private func item(
        _ name: String,
        fileName: String,
        visualStyle: SoundTileVisualStyle,
        column: Int,
        row: Int,
        columnSpan: Int,
        rowSpan: Int
    ) -> SoundItem {
        SoundItem(
            id: UUID(),
            name: name,
            fileName: fileName,
            visualStyle: visualStyle,
            gridPlacement: SoundGridPlacement(
                column: column,
                row: row,
                columnSpan: columnSpan,
                rowSpan: rowSpan
            )
        )
    }

    /// Load default sound libraries grouped by theme.
    private func loadDefaultSounds() {
        let forestSounds: [SoundItem] = [
            item("Campfire", fileName: "forest_campfire.wav", visualStyle: .aurora, column: 0, row: 2, columnSpan: 2, rowSpan: 2),
            item("Wind", fileName: "forest_wind.wav", visualStyle: .canyon, column: 5, row: 4, columnSpan: 2, rowSpan: 2),
            item("Owl", fileName: "forest_owl.wav", visualStyle: .leaves, column: 5, row: 6, columnSpan: 2, rowSpan: 2),
            item("Rainfall", fileName: "forest_rainfall.wav", visualStyle: .nightForest, column: 0, row: 4, columnSpan: 5, rowSpan: 4),
            item("Dry Leaves", fileName: "forest_dry_leaves.wav", visualStyle: .fog, column: 0, row: 8, columnSpan: 7, rowSpan: 2),
            item("Creek", fileName: "forest_creek.wav", visualStyle: .moonMist, column: 0, row: 10, columnSpan: 2, rowSpan: 2),
            item("Woodpecker", fileName: "forest_woodpecker.wav", visualStyle: .moonMist, column: 2, row: 10, columnSpan: 5, rowSpan: 2),
        ]

        let citySounds: [SoundItem] = [
            item("Siren", fileName: "forest_owl.wav", visualStyle: .siren, column: 0, row: 2, columnSpan: 2, rowSpan: 2),
            item("Cars", fileName: "forest_rainfall.wav", visualStyle: .asphalt, column: 0, row: 4, columnSpan: 5, rowSpan: 4),
            item("Footsteps", fileName: "forest_dry_leaves.wav", visualStyle: .crossing, column: 5, row: 4, columnSpan: 2, rowSpan: 2),
            item("Firetruck", fileName: "forest_wind.wav", visualStyle: .station, column: 5, row: 6, columnSpan: 2, rowSpan: 2),
            item("Subway", fileName: "forest_creek.wav", visualStyle: .tunnel, column: 0, row: 8, columnSpan: 7, rowSpan: 2),
            item("Square", fileName: "forest_campfire.wav", visualStyle: .plaza, column: 0, row: 10, columnSpan: 2, rowSpan: 2),
            item("Rooftop Wind", fileName: "forest_wind.wav", visualStyle: .rooftop, column: 2, row: 10, columnSpan: 5, rowSpan: 2),
        ]

        let oceanSounds: [SoundItem] = [
            item("Waves", fileName: "forest_creek.wav", visualStyle: .moonMist, column: 0, row: 2, columnSpan: 3, rowSpan: 3),
            item("Seagulls", fileName: "forest_owl.wav", visualStyle: .aurora, column: 3, row: 2, columnSpan: 4, rowSpan: 3),
            item("Tide Pool", fileName: "forest_rainfall.wav", visualStyle: .fog, column: 0, row: 5, columnSpan: 7, rowSpan: 3),
            item("Driftwood", fileName: "forest_dry_leaves.wav", visualStyle: .canyon, column: 0, row: 8, columnSpan: 4, rowSpan: 4),
            item("Buoy", fileName: "forest_campfire.wav", visualStyle: .bridge, column: 4, row: 8, columnSpan: 3, rowSpan: 2),
            item("Harbor", fileName: "forest_wind.wav", visualStyle: .skyline, column: 4, row: 10, columnSpan: 3, rowSpan: 2),
        ]

        let desertSounds: [SoundItem] = [
            item("Dunes", fileName: "forest_wind.wav", visualStyle: .canyon, column: 0, row: 2, columnSpan: 4, rowSpan: 4),
            item("Mirage", fileName: "forest_rainfall.wav", visualStyle: .aurora, column: 4, row: 2, columnSpan: 3, rowSpan: 2),
            item("Cactus", fileName: "forest_dry_leaves.wav", visualStyle: .leaves, column: 4, row: 4, columnSpan: 3, rowSpan: 2),
            item("Sandstorm", fileName: "forest_creek.wav", visualStyle: .fog, column: 0, row: 6, columnSpan: 7, rowSpan: 2),
            item("Coyote", fileName: "forest_woodpecker.wav", visualStyle: .alley, column: 0, row: 8, columnSpan: 2, rowSpan: 4),
            item("Oasis", fileName: "forest_campfire.wav", visualStyle: .moonMist, column: 2, row: 8, columnSpan: 5, rowSpan: 4),
        ]

        libraries = [
            SoundLibraryModel(
                id: UUID(),
                key: "forest",
                name: "Forest",
                iconStyle: .nightForest,
                backgroundFileName: "forest_background.wav",
                sounds: forestSounds
            ),
            SoundLibraryModel(
                id: UUID(),
                key: "city",
                name: "City",
                iconStyle: .skyline,
                backgroundFileName: "forest_background.wav",
                sounds: citySounds
            ),
            SoundLibraryModel(
                id: UUID(),
                key: "ocean",
                name: "Ocean",
                iconStyle: .bridge,
                backgroundFileName: "forest_background.wav",
                sounds: oceanSounds
            ),
            SoundLibraryModel(
                id: UUID(),
                key: "desert",
                name: "Desert",
                iconStyle: .canyon,
                backgroundFileName: "forest_background.wav",
                sounds: desertSounds
            ),
        ]
    }

    func library(withID id: SoundLibraryModel.ID) -> SoundLibraryModel? {
        libraries.first { $0.id == id }
    }
}
