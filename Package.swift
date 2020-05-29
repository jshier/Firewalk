// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Firewalk",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.7.0"),
    ],
    targets: [
        .target(name: "FirewalkApp", dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ]),
        .target(name: "firewalk", dependencies: ["FirewalkApp"]),
        .testTarget(name: "FirewalkTests", dependencies: [
            .target(name: "FirewalkApp"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
