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
            targets: ["MosMetroMapKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage",                            .upToNextMajor(from: "5.0.0")),
        .package(name: "HMSegmentedControl", url: "https://github.com/HeshamMegid/HMSegmentedControl",                   .branch("master")),
    ],
    targets: [
        .target(
            name: "MosMetroMapKit",
            dependencies: [
                "SDWebImage",
                "HMSegmentedControl"
            ],
            resources: [
                .process("Constants/Fonts"),
                .process("Metro/Localization"),
                .process("Metro/Icons/Original"),
                .process("Metro/Icons/Inverted"),
                .process("SwiftDate/Formatters/RelativeFormatter/langs")
            ]
        ),
        .testTarget(
            name: "MosMetroMapKitTests",
            dependencies: ["MosMetroMapKit"]),
    ]
)
