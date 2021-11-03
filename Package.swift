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
    ],
    targets: [
        .target(
            name: "MosMetroMapKit",
            dependencies: [
            ],
            resources: [
                .process("Constants/Fonts"),
                .process("Metro/Localization"),
                .process("Metro/Icons/Original"),
                .process("Metro/Icons/Inverted"),
                .process("SwiftDate/Formatters/RelativeFormatter/langs")
            ]
        ),
//        .testTarget(
//            name: "MosMetroMapKitTests",
//            dependencies: ["MosMetroMapKit"]),
    ]
)
