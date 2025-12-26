import Foundation
import PathKit

enum TestFixtures {
    static let rootPath = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures")
        .path

    static var root: Path {
        Path(rootPath)
    }
}
