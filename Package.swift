// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Soundbook",
    platforms: [
        .iOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/SwiftAVFoundation.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Soundbook",
            dependencies: ["AVFoundation"]
        )
    ]
)