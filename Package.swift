// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FengNiao",
    products: [
        .executable(name: "FengNiao", targets: ["FengNiao"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.1"),
        .package(url: "https://github.com/benoit-pereira-da-silva/CommandLine.git", from: "4.0.0"),
        .package(url: "https://github.com/kylef/Spectre.git", from: "0.9.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.0")
    ],
    targets: [
        .target(name: "FengNiaoKit", dependencies: ["Rainbow", "PathKit"]),
        .target(name: "FengNiao", dependencies: ["FengNiaoKit", "CommandLineKit"]),
        .testTarget(name: "FengNiaoKitTests", dependencies: ["FengNiaoKit", "Spectre"], exclude: ["Tests/Fixtures"]),
    ]
)
