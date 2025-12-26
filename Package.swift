// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "FengNiao",
    platforms: [.macOS(.v10_13)],
    products: [
        .executable(name: "FengNiao", targets: ["FengNiao"]),
        .library(name: "FengNiaoKit", targets: ["FengNiaoKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1")
    ],
    targets: [
        .target(name: "FengNiaoKit", dependencies: ["Rainbow", "PathKit"]),
        .executableTarget(
            name: "FengNiao",
            dependencies: [
                "FengNiaoKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(name: "FengNiaoKitTests", dependencies: ["FengNiaoKit"], exclude: ["../Fixtures"]),
        .testTarget(name: "FengNiaoCLITests", dependencies: ["FengNiao"])
    ]
)
