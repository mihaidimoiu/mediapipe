// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPipe",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Main products - these are what users will import
        .library(
            name: "MediaPipeTasksCommon",
            targets: ["MediaPipeTasksCommon", "MediaPipeTasksCommonWrapper"]),
        .library(
            name: "MediaPipeTasksVision",
            targets: ["MediaPipeTasksVision"]),
        .library(
            name: "MediaPipeTasksText",
            targets: ["MediaPipeTasksText"]),
        .library(
            name: "MediaPipeTasksAudio",
            targets: ["MediaPipeTasksAudio"]),
    ],
    targets: [
        // MediaPipeTasksCommon - Base framework
        // Contains core functionality shared across all task types
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.26/MediaPipeTasksCommon.xcframework.zip",
            checksum: "8d4612908765bb4de7be9280e422ba5a7683e0cde9d20f98cb5e4498c4f2ae3a"
        ),

        // Wrapper target for MediaPipeTasksCommon to add system framework dependencies
        .target(
            name: "MediaPipeTasksCommonWrapper",
            dependencies: ["MediaPipeTasksCommon"],
            path: "Sources/MediaPipeTasksCommonWrapper",
            linkerSettings: [
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("AssetsLibrary"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreImage"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreVideo"),
                .linkedLibrary("c++")
            ]
        ),

        // MediaPipeTasksVision - Vision task APIs
        // Includes: object detection, image classification, face detection, etc.
        .binaryTarget(
            name: "MediaPipeTasksVision",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.26/MediaPipeTasksVision.xcframework.zip",
            checksum: "5df7f2f9f4d3f688a915c9918a0c37afe0157f93cec372ba6b34f37d980acc3e"
        ),

        // MediaPipeTasksText - Text task APIs
        // Includes: text classification, text embedding, etc.
        .binaryTarget(
            name: "MediaPipeTasksText",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.26/MediaPipeTasksText.xcframework.zip",
            checksum: "ba4ba3f869f905ffdd8a017c43ac27ee8df28c2bb11cb1bd2c08454503294f6e"
        ),

        // MediaPipeTasksAudio - Audio task APIs
        // Includes: audio classification, etc.
        .binaryTarget(
            name: "MediaPipeTasksAudio",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.26/MediaPipeTasksAudio.xcframework.zip",
            checksum: "b9274ea8441bafbfd2e0fd840fe991b3d9c38bcae1a17ebd2e1c7a336d1077c0"
        ),
    ]
)
