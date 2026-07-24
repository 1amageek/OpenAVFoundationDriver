// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "OpenAVFoundationDriver",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "OpenAVFoundationDriver",
            targets: ["OpenAVFoundationDriver"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/1amageek/OpenCoreMedia.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/1amageek/OpenCoreVideo.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "OpenAVFoundationDriver",
            dependencies: [
                "OpenCoreMedia",
                "OpenCoreVideo"
            ]
        ),
        .testTarget(
            name: "OpenAVFoundationDriverTests",
            dependencies: ["OpenAVFoundationDriver"]
        )
    ],
    swiftLanguageModes: [.v6]
)
