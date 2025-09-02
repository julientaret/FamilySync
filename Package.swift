// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FamilySync",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/appwrite/sdk-for-swift", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "FamilySync",
            dependencies: [
                .product(name: "Appwrite", package: "sdk-for-swift")
            ]
        )
    ]
)