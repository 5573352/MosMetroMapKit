// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MosMetroMapKit",
    defaultLocalization: "ru",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MosMetroMapKit",
            targets: ["MosMetroMapKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ivanvorobei/SPAlert", .exact("2.1.4")),
        .package(url: "https://github.com/exyte/Macaw", .upToNextMajor(from: "0.9.7")),
        .package(url: "https://github.com/malcommac/SwiftDate", .upToNextMajor(from: "6.3.1")),
        .package(url: "https://github.com/scenee/FloatingPanel", .upToNextMajor(from: "2.4.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/marcosgriselli/ViewAnimator", .upToNextMajor(from: "3.1.0")),
        .package(name: "Localize_Swift", url: "https://github.com/marmelroy/Localize-Swift", .upToNextMajor(from: "3.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MosMetroMapKit",
            dependencies: [
                "ViewAnimator",
                "SPAlert",
                "SwiftDate",
                "SwiftyJSON",
                "Macaw",
                "FloatingPanel",
                "Localize_Swift"
            ],
            resources: [
                .process("Constants/Fonts"),
                .process("Metro/Localization")
            ]
        ),
        .testTarget(
            name: "MosMetroMapKitTests",
            dependencies: ["MosMetroMapKit"]),
    ]
)
