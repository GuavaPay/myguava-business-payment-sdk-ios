// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyGuavaPaymentSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MyGuavaPaymentSDK",
            type: .static,
            targets: ["MyGuavaPaymentSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.2"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.7"),
        .package(url: "https://github.com/GuavaPay/Guavapay3DS2", from: "0.0.1"),
        .package(url: "https://github.com/Juanpe/SkeletonView.git", from: "1.30.4"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.54.0")
    ],
    targets: [
        .target(
            name: "MyGuavaPaymentSDK",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "Guavapay3DS2", package: "Guavapay3DS2"),
                .product(name: "SwiftGuavapay3DS2", package: "Guavapay3DS2"),
                .product(name: "SkeletonView", package: "SkeletonView"),
                .product(name: "Sentry", package: "sentry-cocoa")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MyGuavaPaymentSDKTests",
            dependencies: ["MyGuavaPaymentSDK"]
        )
    ],
    swiftLanguageModes: [.v5]
)
