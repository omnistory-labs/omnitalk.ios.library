// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "omnitalk.ios.sdk",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "omnitalk.ios.sdk",
            targets: ["OmnitalkSdkBundle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/omnistory-labs/omnitalk.ios.webrtc.sdk", branch: "feature/init"),
    ],
    targets: [
        .binaryTarget(name: "OmnitalkSdk", path: "OmnitalkSdk.xcframework"),
        .target(
            name: "OmnitalkSdkBundle",
            dependencies: [
                .target(name: "OmnitalkSdk"),
                "omnitalk.ios.webrtc.sdk"
            ],
            path: "OmnitalkSdkBundle"
        ),
    ]
)
