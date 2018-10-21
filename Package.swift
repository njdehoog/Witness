// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Witness",
    products: [
        .library(
            name: "Witness",
            targets: ["Witness"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Witness",
            dependencies: []),
        .testTarget(
            name: "WitnessTests",
            dependencies: ["Witness"]),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
