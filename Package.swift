// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XnTemplate",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "XnTemplate", targets: ["XnTemplate"]),
    ],
    targets: [
        .target(name: "XnTemplate"),
        .testTarget(name: "XnTemplateTests", dependencies: ["XnTemplate"]),
        .testTarget(name: "XnTemplatePerformance", dependencies: ["XnTemplate"]),
    ]
)
