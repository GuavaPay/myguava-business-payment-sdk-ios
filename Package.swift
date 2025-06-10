// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GuavapayPaymentSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "GuavapayPaymentSDK",
            targets: ["GuavapayPaymentSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GuavapayPaymentSDK",
            path: "Sources/GuavapayPaymentSDK",
            exclude: []
        ),
        .testTarget(
            name: "GuavapayPaymentSDKTests",
            dependencies: ["GuavapayPaymentSDK"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
