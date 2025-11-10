// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Lymbo",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Lymbo",
            targets: ["Lymbo"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Lymbo",
            dependencies: []),
    ]
)

