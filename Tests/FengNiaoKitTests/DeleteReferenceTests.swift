#if os(macOS)
import PathKit
import Testing
@testable import FengNiaoKit

@Suite("FengNiao Delete the xcodeproj image reference")
struct DeleteReferenceTests {
    private let fixtures = TestFixtures.root

    @Test("removes the reference")
    func removesTheReference() throws {
        let file = fixtures + "DeleteReference"
        let fileDes = fixtures + "DeleteReferenceCopy"

        try file.copy(fileDes)
        defer {
            try? fileDes.delete()
        }

        let projectPath = fileDes + "FengNiao.xcodeproj" + "project.pbxproj"
        let fileProjectPath = file + "FengNiao.xcodeproj" + "project.pbxproj"
        let fileContents: String = try fileProjectPath.read()
        var projectContents: String = try projectPath.read()

        #expect(fileContents == projectContents)
        let path = FileInfo(path: "/text/file1.png")
        FengNiao.deleteReference(projectFilePath: projectPath, deletedFiles: [path])

        projectContents = try projectPath.read()
        #expect(fileContents != projectContents)
        #expect(!projectContents.contains("file1.png"))
        #expect(!projectContents.hasPrefix("\n"))
    }
}
#endif
