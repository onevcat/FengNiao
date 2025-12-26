import PathKit
import Testing
@testable import FengNiaoKit

@Suite("File Info Structure")
struct FileInfoTests {
    private let fixtures = TestFixtures.root

    @Test("creates a file info struct")
    func createsFileInfoStruct() {
        let path = fixtures + "FileInfo/file_1_byte"
        let fileInfo = FileInfo(path: path.string)

        #expect(fileInfo.path == path)
        #expect(fileInfo.size == 1)
    }

    @Test("generates readable size text")
    func generatesReadableSizeText() {
        let rootPath = fixtures + "FileInfo"
        let root = FileInfo(path: rootPath.string)
        #expect(root.readableSize == "1.23 KB")

        let file1BytePath = fixtures + "FileInfo/file_1_byte"
        let file1Byte = FileInfo(path: file1BytePath.string)
        #expect(file1Byte.readableSize == "1 B")
    }
}
