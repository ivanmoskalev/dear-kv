// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XnKV",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "XnKV", targets: ["XnKV"]),
        .library(name: "liblmdb", targets: ["liblmdb"])
    ],
    targets: [
        .target(name: "XnKV", dependencies: ["liblmdb"]),
        .target(name: "liblmdb"),
        .testTarget(name: "XnKVTests", dependencies: ["XnKV"]),
        .testTarget(name: "XnKVPerformance", dependencies: ["XnKV"]),
    ]
)
