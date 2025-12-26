import Testing
@testable import FengNiaoKit

@Suite("FengNiao File Filter")
struct FileFilterTests {
    @Test("filters simple unused files")
    func filtersSimpleUnusedFiles() {
        let all: [String: Set<String>] = [
            "face": ["face.png"],
            "book": ["book.png"],
            "moon": ["moon.png"]
        ]
        let used: Set<String> = ["book"]

        let result = FengNiao.filterUnused(from: all, used: used)
        let expected: Set<String> = ["face.png", "moon.png"]
        #expect(result == expected)
    }

    @Test("filters same name files correctly")
    func filtersSameNameFilesCorrectly() {
        let all: [String: Set<String>] = [
            "face": ["face1.png", "face2.png"],
            "book": ["book.png"],
            "moon": ["moon.png"]
        ]
        let used: Set<String> = ["book"]

        let result = FengNiao.filterUnused(from: all, used: used)
        let expected: Set<String> = ["face1.png", "face2.png", "moon.png"]
        #expect(result == expected)
    }

    @Test("does not filter similar pattern")
    func doesNotFilterSimilarPattern() {
        let all: [String: Set<String>] = [
            "face": ["face.png"],
            "image01": ["image01.png"],
            "image02": ["image02.png"],
            "image03": ["image03.png"],
            "1_set": ["001_set.jpg"],
            "2_set": ["002_set.jpg"],
            "3_set": ["003_set.jpg"],
            "middle_01_bird": ["middle_01_bird@2x.png"],
            "middle_02_bird": ["middle_02_bird@2x.png"],
            "middle_03_bird": ["middle_03_bird@2x.png"],
            "suffix_1": ["suffix_1.jpg"],
            "suffix_2": ["suffix_2.jpg"],
            "suffix_3": ["suffix_3.jpg"],
            "unused_1": ["unused_1.png"],
            "unused_2": ["unused_2.png"],
            "unused_3": ["unused_3.png"]
        ]
        let used: Set<String> = ["image%02d", "%d_set", "middle_%d_bird", "suffix_"]
        let result = FengNiao.filterUnused(from: all, used: used)
        let expected: Set<String> = ["face.png", "unused_1.png", "unused_2.png", "unused_3.png"]
        #expect(result == expected)
    }
}
