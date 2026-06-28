// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GameAnalyticsSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "GameAnalyticsSDK", targets: ["GameAnalyticsSDK"]),
    ],
    targets: [
        .target(name: "GameAnalyticsSDK"),
        .testTarget(name: "GameAnalyticsSDKTests", dependencies: ["GameAnalyticsSDK"]),
    ]
)
