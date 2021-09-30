// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MosMetroMapKit",
    defaultLocalization: "ru",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MosMetroMapKit",
            targets: ["MosMetroMapKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ivanvorobei/SPAlert",                              .exact("2.1.4")),
        .package(url: "https://github.com/exyte/Macaw",                                      .upToNextMajor(from: "0.9.7")),
        .package(url: "https://github.com/SDWebImage/SDWebImage",                            .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/malcommac/SwiftDate",                              .upToNextMajor(from: "6.3.1")),
        .package(url: "https://github.com/scenee/FloatingPanel",                             .upToNextMajor(from: "2.4.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON",                            .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/marcosgriselli/ViewAnimator",                      .upToNextMajor(from: "3.1.0")),
        .package(name: "Localize_Swift", url: "https://github.com/marmelroy/Localize-Swift", .upToNextMajor(from: "3.2.0"))
    ],
    targets: [
        .target(
            name: "MosMetroMapKit",
            dependencies: [
                "SPAlert",
                "Macaw",
                "SwiftDate",
                "SDWebImage",
                "FloatingPanel",
                "SwiftyJSON",
                "ViewAnimator",
                "Localize_Swift"
            ],
            resources: [
                .process("Constants/Fonts"),
                .process("Metro/Localization"),
                .process("Metro/Icons/Original"),
                .process("Metro/Icons/Inverted")
            ]
        ),
        .testTarget(
            name: "MosMetroMapKitTests",
            dependencies: ["MosMetroMapKit"]),
    ]
)
