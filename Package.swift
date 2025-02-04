// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DearKV",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "DearKV", targets: ["DearKV"]),
        .library(name: "liblmdb", targets: ["liblmdb"])
    ],
    targets: [
        .target(name: "DearKV", dependencies: ["liblmdb"]),
        .target(name: "liblmdb"),
        .testTarget(name: "DearKVTests", dependencies: ["DearKV"]),
        .testTarget(name: "DearKVPerformance", dependencies: ["DearKV"]),
    ]
)
