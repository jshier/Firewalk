// swift-tools-version:5.2
import PackageDescription

let package = Package(name: "Firewalk",
                      platforms: [.macOS(.v10_15)],
                      dependencies: [.package(url: "https://github.com/vapor/vapor.git", from: "4.10.0")],
                      targets: [.target(name: "firewalk", dependencies: ["FirewalkApp"]),
                                .target(name: "FirewalkApp", dependencies: [.product(name: "Vapor", package: "vapor")]),
                                .testTarget(name: "FirewalkTests", dependencies: [.target(name: "FirewalkApp"),
                                                                                  .product(name: "XCTVapor", package: "vapor")])])
