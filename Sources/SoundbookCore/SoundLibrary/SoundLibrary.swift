import Foundation

/// Describes the relative visual size of a tile in the sound grid.
enum SoundTileSize: String, Codable {
    case hero
    case large
    case medium
    case small
    case wide
}

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

/// One playable sound item shown as a rounded grid button.
struct SoundItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let fileName: String
    let visualStyle: SoundTileVisualStyle
    let tileSize: SoundTileSize
}

/// A themed group of sounds selectable from the bottom library selector.
struct SoundLibraryModel: Identifiable, Codable {
    let id: UUID
    let key: String
    let name: String
    let iconStyle: SoundTileVisualStyle
    let sounds: [SoundItem]
}

class SoundLibrary {
    static let shared = SoundLibrary()

    private(set) var libraries: [SoundLibraryModel] = []

    init() {
        loadDefaultSounds()
    }

    /// Load default sound libraries grouped by theme.
    private func loadDefaultSounds() {
        let forestSounds: [SoundItem] = [
            SoundItem(id: UUID(), name: "Campfire", fileName: "forest_campfire.mp3", visualStyle: .aurora, tileSize: .small),
            SoundItem(id: UUID(), name: "Rainfall", fileName: "forest_rainfall.mp3", visualStyle: .nightForest, tileSize: .hero),
            SoundItem(id: UUID(), name: "Creek", fileName: "forest_creek.mp3", visualStyle: .moonMist, tileSize: .small),
            SoundItem(id: UUID(), name: "Owl", fileName: "forest_owl.mp3", visualStyle: .leaves, tileSize: .wide),
            SoundItem(id: UUID(), name: "Wind", fileName: "forest_wind.mp3", visualStyle: .canyon, tileSize: .medium),
            SoundItem(id: UUID(), name: "Dry Leaves", fileName: "forest_dry_leaves.mp3", visualStyle: .fog, tileSize: .large),
            SoundItem(id: UUID(), name: "Monkey", fileName: "forest_monkey.mp3", visualStyle: .nightForest, tileSize: .wide),
            SoundItem(id: UUID(), name: "Woodpecker", fileName: "forest_woodpecker.mp3", visualStyle: .moonMist, tileSize: .medium),
        ]

        let citySounds: [SoundItem] = [
            SoundItem(id: UUID(), name: "Siren", fileName: "city_siren.mp3", visualStyle: .siren, tileSize: .small),
            SoundItem(id: UUID(), name: "Cars", fileName: "city_cars.mp3", visualStyle: .asphalt, tileSize: .hero),
            SoundItem(id: UUID(), name: "Footsteps", fileName: "city_footsteps.mp3", visualStyle: .crossing, tileSize: .small),
            SoundItem(id: UUID(), name: "Firetruck", fileName: "city_firetruck.mp3", visualStyle: .station, tileSize: .wide),
            SoundItem(id: UUID(), name: "Bicycles", fileName: "city_bicycles.mp3", visualStyle: .bridge, tileSize: .medium),
            SoundItem(id: UUID(), name: "Subway", fileName: "city_subway.mp3", visualStyle: .tunnel, tileSize: .large),
            SoundItem(id: UUID(), name: "Square", fileName: "city_square.mp3", visualStyle: .plaza, tileSize: .wide),
            SoundItem(id: UUID(), name: "Rooftop Wind", fileName: "city_rooftop_wind.mp3", visualStyle: .rooftop, tileSize: .medium),
        ]

        libraries = [
            SoundLibraryModel(
                id: UUID(),
                key: "forest",
                name: "Forest",
                iconStyle: .nightForest,
                sounds: forestSounds
            ),
            SoundLibraryModel(
                id: UUID(),
                key: "city",
                name: "City",
                iconStyle: .skyline,
                sounds: citySounds
            ),
        ]
    }

    func library(withID id: SoundLibraryModel.ID) -> SoundLibraryModel? {
        libraries.first { $0.id == id }
    }
}