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

    @Test("treats generated Objective-C asset symbols in implementation files as usage")
    func treatsGeneratedObjectiveCAssetSymbolsAsUsage() throws {
        let project = fixtures + "GeneratedAssetSymbolObjC"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png"],
            searchInFileExtensions: ["m"]
        )
        let result = try fengniao.unusedFiles()
        let fileNames = Set(result.map { $0.fileName })
        let expected: Set<String> = ["ic_unused.png"]
        #expect(fileNames == expected)
    }

    @Test("treats generated Objective-C asset symbols in headers as usage conservatively")
    func treatsGeneratedObjectiveCAssetSymbolsInHeadersAsUsageConservatively() throws {
        let project = fixtures + "GeneratedAssetSymbolHeader"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png"],
            searchInFileExtensions: ["h"]
        )
        let result = try fengniao.unusedFiles()
        let fileNames = Set(result.map { $0.fileName })
        let expected: Set<String> = ["ic_unused.png"]
        #expect(fileNames == expected)
    }
}
