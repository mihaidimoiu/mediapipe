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
        .library(
            name: "MediaPipeTasksGenAI",
            targets: ["MediaPipeTasksGenAI"]),
        .library(
            name: "MediaPipeTasksGenAIC",
            targets: ["MediaPipeTasksGenAIC", "MediaPipeTasksGenAICWrapper"]),
    ],
    targets: [
        // MediaPipeTasksCommon - Base framework
        // Contains core functionality shared across all task types
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksCommon.xcframework.zip",
            checksum: "e7972c14cd37c0a34ce9f8fbb7df7dafd87f061742c3d5ad69ec0f2ba9d4e507"
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
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksVision.xcframework.zip",
            checksum: "5f6eeb49c3ec0e91e3c4dc4bd888e54af6a00c9770af717fca773379ed807109"
        ),

        // MediaPipeTasksText - Text task APIs
        // Includes: text classification, text embedding, etc.
        .binaryTarget(
            name: "MediaPipeTasksText",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksText.xcframework.zip",
            checksum: "5c691d75c9f5611760bc4024223b2616d6a64cc23ca5598adea5d6c7e3cf0ec6"
        ),

        // MediaPipeTasksAudio - Audio task APIs
        // Includes: audio classification, etc.
        .binaryTarget(
            name: "MediaPipeTasksAudio",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksAudio.xcframework.zip",
            checksum: "6b6b615786fdd5185b201f46d50d19770059aea3ef0014e8473765c1ad64691c"
        ),

        // MediaPipeTasksGenAI - Generative AI APIs (prebuilt, source not open)
        // Includes: LLM inference (deprecated in favor of LiteRT-LM)
        .binaryTarget(
            name: "MediaPipeTasksGenAI",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksGenAI.xcframework.zip",
            checksum: "e099eb727b6bc59677e5ad2dd6477386587430a1409abae0a3dbc276f51f65db"
        ),

        // MediaPipeTasksGenAIC - Generative AI C API (prebuilt, source not open)
        .binaryTarget(
            name: "MediaPipeTasksGenAIC",
            url: "https://github.com/mihaidimoiu/mediapipe/releases/download/v0.10.33/MediaPipeTasksGenAIC.xcframework.zip",
            checksum: "40b7a638750c0842c6bc844dfc252a6413627dcc1b1f4c8e3a29342685ec6eaf"
        ),

        // Wrapper target for MediaPipeTasksGenAIC to add system framework and force_load dependencies
        .target(
            name: "MediaPipeTasksGenAICWrapper",
            dependencies: ["MediaPipeTasksGenAIC"],
            path: "Sources/MediaPipeTasksGenAICWrapper",
            linkerSettings: [
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("Metal"),
                .linkedFramework("OpenGLES"),
                .linkedLibrary("c++")
            ]
        ),
    ]
)
