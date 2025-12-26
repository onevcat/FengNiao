import Testing
@testable import FengNiao

@Suite("CLI Parsing")
struct CLIParsingTests {
    @Test("defaults are applied")
    func defaultsAreApplied() throws {
        let command = try FengNiaoCommand.parse([])
        #expect(command.project == ".")
        #expect(command.force == false)
        #expect(command.exclude.isEmpty)
        #expect(command.resourceExtensions == ["imageset", "jpg", "png", "gif", "pdf"])
        #expect(command.fileExtensions == ["h", "m", "mm", "swift", "xib", "storyboard", "plist"])
        #expect(command.skipProjReference == false)
        #expect(command.xcodeWarnings == false)
        #expect(command.listOnly == false)
    }

    @Test("parses simple flags")
    func parsesSimpleFlags() throws {
        let command = try FengNiaoCommand.parse([
            "--force",
            "--skip-proj-reference",
            "--xcode-warnings",
            "--list-only"
        ])
        #expect(command.force)
        #expect(command.skipProjReference)
        #expect(command.xcodeWarnings)
        #expect(command.listOnly)
    }

    @Test("parses options with values")
    func parsesOptionsWithValues() throws {
        let command = try FengNiaoCommand.parse([
            "--project", "/tmp/project",
            "--exclude", "Carthage", "Pods",
            "--resource-extensions", "png", "jpg",
            "--file-extensions", "swift", "xib"
        ])
        #expect(command.project == "/tmp/project")
        #expect(command.exclude == ["Carthage", "Pods"])
        #expect(command.resourceExtensions == ["png", "jpg"])
        #expect(command.fileExtensions == ["swift", "xib"])
    }

    @Test("parses short flags")
    func parsesShortFlags() throws {
        let command = try FengNiaoCommand.parse([
            "-p", "./Sample",
            "-e", "A", "B",
            "-r", "png",
            "-f", "swift"
        ])
        #expect(command.project == "./Sample")
        #expect(command.exclude == ["A", "B"])
        #expect(command.resourceExtensions == ["png"])
        #expect(command.fileExtensions == ["swift"])
    }
}
