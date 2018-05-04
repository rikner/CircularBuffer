// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CircularBuffer",
    products: [
        .library(name: "CircularBuffer", targets: ["CircularBuffer"]),
    ],
    targets: [
        .target(name: "CircularBuffer", dependencies: []),
        .testTarget(name: "CircularBufferTests", dependencies: ["CircularBuffer"]),
    ]
)
