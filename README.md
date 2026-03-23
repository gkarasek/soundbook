# soundbook

An iOS app that emulates contextual sounds to enhance your audiobook and book reading experience.

## Features

- 🎵 **Sound Synchronization**: Align ambient sounds and effects with book narration
- 📚 **Multi-Format Support**: Compatible with various audiobook formats
- 🎧 **Customizable Sound Libraries**: Choose from curated sound collections or create your own
- 📍 **Scene-Based Audio**: Automatic sound triggers based on narrative elements
- 🎚️ **Volume Control**: Independent mixing of narration and sound effects
- ✏️ **Bookmark Integration**: Save favorite moments with associated sound profiles

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI / UIKit
- **Audio**: AVFoundation
- **Storage**: CoreData / SQLite

## Getting Started

### Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

### Installation

```bash
git clone https://github.com/gkarasek/soundbook.git
cd soundbook
open Soundbook.xcodeproj
```

### Build & Run

1. Select the **SoundbookApp** scheme (not the Swift package executable).
2. Choose an iPhone simulator (or device).
3. Press `Cmd + R` to build and run.

The UI and logic live in the **SoundbookCore** Swift package (`Package.swift`); the **SoundbookApp** target is a thin iOS app shell with a real `Info.plist` and bundle ID (`com.gkarasek.soundbook`), which avoids simulator crashes from a missing `CFBundleIdentifier`.

To open only the package (e.g. for SwiftPM tooling): `open Package.swift`.

## Architecture

- **Audio Engine**: Handles sound playback and synchronization
- **Content Parser**: Processes audiobooks and reading metadata
- **Sound Library**: Manages sound effects and ambient audio
- **UI Layer**: SwiftUI-based interface for playback and settings

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

MIT License

## Contact

Created by [@gkarasek](https://github.com/gkarasek)