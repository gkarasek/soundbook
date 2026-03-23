// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Soundbook",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "SoundbookCore", targets: ["SoundbookCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SoundbookCore",
            dependencies: [],
            path: "Sources/SoundbookCore"
        )
    ]
)
