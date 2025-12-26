import PathKit
import Testing
@testable import FengNiaoKit

@Suite("FengNiao Resource Searcher")
struct ResourceSearcherTests {
    private let fixtures = TestFixtures.root

    @Test("searches resources in a simple project")
    func searchesResourcesInSimpleProject() {
        let project = fixtures + "SimpleResource"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png", "jpg", "imageset"],
            searchInFileExtensions: []
        )
        let result = fengniao.allResourceFiles()
        let expected: [String: Set<String>] = [
            "file1": [(project + "file1.png").string],
            "file2": [(project + "file2.jpg").string],
            "images": [(project + "images.imageset").string]
        ]
        #expect(result == expected)
    }

    @Test("properly skips resources in bundle")
    func properlySkipsResourcesInBundle() {
        let project = fixtures + "ResourcesInBundle"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: ["Ignore"],
            resourceExtensions: ["png", "jpg", "imageset"],
            searchInFileExtensions: []
        )
        let result = fengniao.allResourceFiles()
        let expected: [String: Set<String>] = [
            "normal": [(project + "normal.png").string],
            "image": [(project + "Assets.xcassets/image.imageset").string]
        ]
        #expect(result == expected)
    }

    @Test("does not skip same files with scale suffix")
    func doesNotSkipSameFilesWithScaleSuffix() {
        let project = fixtures + "ResourcesSuffix"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png"],
            searchInFileExtensions: []
        )
        let result = fengniao.allResourceFiles()
        let expected: [String: Set<String>] = [
            "image": [(project + "image@2x.png").string, (project + "image@3x.png").string],
            "cloud": [(project + "cloud.png").string]
        ]
        #expect(result == expected)
    }
}
