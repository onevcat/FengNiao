import PathKit
import Testing
@testable import FengNiaoKit

@Suite("FengNiao Generated Asset Symbols")
struct GeneratedAssetSymbolTests {
    private let fixtures = TestFixtures.root

    @Test("treats generated Swift asset symbols as usage")
    func treatsGeneratedSwiftAssetSymbolsAsUsage() throws {
        let project = fixtures + "GeneratedAssetSymbol"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png"],
            searchInFileExtensions: ["swift"]
        )
        let result = try fengniao.unusedFiles()
        let fileNames = Set(result.map { $0.fileName })
        let expected: Set<String> = ["ic_unused.png"]
        #expect(fileNames == expected)
    }
}
