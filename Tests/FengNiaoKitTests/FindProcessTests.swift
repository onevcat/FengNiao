import PathKit
import Testing
@testable import FengNiaoKit

@Suite("Find Process")
struct FindProcessTests {
    private let fixtures = TestFixtures.root

    @Test("gets proper files")
    func getsProperFiles() {
        let project = fixtures + "FindProcess"
        let process = ExtensionFindProcess(path: project.string, extensions: ["swift"], excluded: [])
        let result = process?.execute()
        let expected = Set(["Folder1/ignore_ext.swift"].map { (project + $0).string })
        #expect(result == expected)
    }

    @Test("gets proper files with exclude pattern")
    func getsProperFilesWithExcludePattern() {
        let project = fixtures + "FindProcess"
        let process = ExtensionFindProcess(
            path: project.string,
            extensions: ["png", "jpg"],
            excluded: ["Folder1/Ignore", "Folder2/ignore_file.jpg"]
        )
        let result = process?.execute()
        let expected = Set([
            "file1.png",
            "Folder1/file2.png",
            "Folder1/SubFolder/file3.jpg",
            "Folder2/file4.jpg"
        ].map { (project + $0).string })
        #expect(result == expected)
    }
}
