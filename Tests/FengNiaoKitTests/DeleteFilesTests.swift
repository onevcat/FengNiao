#if os(macOS)
import PathKit
import Testing
@testable import FengNiaoKit

@Suite("FengNiao Deleting File")
struct DeleteFilesTests {
    private let fixtures = TestFixtures.root

    @Test("deletes specified file")
    func deletesSpecifiedFile() throws {
        let file = fixtures + "DeleteFiles/file_in_root"
        let folder = fixtures + "DeleteFiles/Folder"

        let fileDes = fixtures + "DeleteFiles/file_in_root_copy"
        let folderDes = fixtures + "DeleteFiles/Folder_Copy"

        try file.copy(fileDes)
        try folder.copy(folderDes)

        defer {
            try? fileDes.delete()
            try? folderDes.delete()
        }

        #expect(fileDes.exists)
        #expect(folderDes.exists)

        let (deleted, failed) = FengNiao.delete([fileDes, folderDes].map { FileInfo(path: $0.string) })

        #expect(failed.isEmpty)
        #expect(deleted.count == 2)
        #expect(!fileDes.exists)
        #expect(!folderDes.exists)
    }
}
#endif
