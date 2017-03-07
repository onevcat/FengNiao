import PackageDescription

let package = Package(
    name: "FengNiao",
    dependencies: [
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2),
        .Package(url: "https://github.com/jatoben/CommandLine", "3.0.0-pre1"),
        .Package(url: "https://github.com/Swiftline/Swiftline.git", majorVersion: 0, minor: 5),
    ]
)