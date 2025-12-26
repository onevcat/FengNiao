import PathKit
import Testing
@testable import FengNiaoKit

@Suite("FengNiao Used String Searcher")
struct UsedStringSearcherTests {
    private let fixtures = TestFixtures.root

    @Test("works for txt file")
    func worksForTxtFile() {
        let project = fixtures + "FileStringSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png", "jpg"],
            searchInFileExtensions: ["txt"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = ["image", "another-image"]
        #expect(result == expected)
    }

    @Test("works for swift file")
    func worksForSwiftFile() {
        let project = fixtures + "FileStringSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png", "jpg"],
            searchInFileExtensions: ["swift"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = [
            "common.login",
            "common.logout",
            "live_btn_connect",
            "live_btn_connect",
            "name-key",
            "无法支持"
        ]
        #expect(result == expected)
    }

    @Test("works for objc file")
    func worksForObjcFile() {
        let project = fixtures + "FileStringSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png", "jpg"],
            searchInFileExtensions: ["m", "mm"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = [
            "info.error.memory.full.confirm",
            "info.error.memory.full.ios",
            "image",
            "name-of-mm",
            "C",
            "image-from-mm"
        ]
        #expect(result == expected)
    }

    @Test("works for xib file")
    func worksForXibFile() {
        let project = fixtures + "FileStringSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png"],
            searchInFileExtensions: ["xib", "storyboard"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = [
            "profile_image",
            "bottom",
            "top",
            "left",
            "right",
            "normal"
        ]
        #expect(result == expected)
    }

    @Test("works for plist file")
    func worksForPlistFile() {
        let project = fixtures + "PlistSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: [],
            searchInFileExtensions: ["plist"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = ["some_image", "some_type", "Some Image"]
        #expect(result == expected)
    }

    @Test("works for pbxproj file")
    func worksForPbxprojFile() {
        let project = fixtures + "PbxprojSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: [],
            searchInFileExtensions: ["pbxproj"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = ["AppIcon", "MessagesIcon", "iMessage App Icon", "Complication"]
        #expect(result == expected)
    }

    @Test("searches in subfolder")
    func searchesInSubfolder() {
        let project = fixtures + "SubFolderSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: [],
            resourceExtensions: ["png", "jpg"],
            searchInFileExtensions: ["m", "xib"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = [
            "profile_image",
            "bottom",
            "top",
            "info.error.memory.full.confirm",
            "info.error.memory.full.ios",
            "image"
        ]
        #expect(result == expected)
    }

    @Test("searches excluded folder")
    func searchesExcludedFolder() {
        let project = fixtures + "SubFolderSearcher"
        let fengniao = FengNiao(
            projectPath: project.string,
            excludedPaths: ["SubFolder2"],
            resourceExtensions: ["png", "jpg"],
            searchInFileExtensions: ["m", "xib"]
        )
        let result = fengniao.allUsedStringNames()
        let expected: Set<String> = [
            "info.error.memory.full.confirm",
            "info.error.memory.full.ios",
            "image"
        ]
        #expect(result == expected)
    }
}
