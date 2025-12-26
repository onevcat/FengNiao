import ArgumentParser
import Foundation
import Rainbow
import FengNiaoKit
import PathKit

@main
struct FengNiaoCommand: ParsableCommand {
    private static let appVersion = "0.11.0"
    private static let exitUnusedResources: Int32 = 1
    private static let exitUsage: Int32 = 64

    static let configuration = CommandConfiguration(
        commandName: "fengniao",
        abstract: "Find and delete unused resources in Xcode projects.",
        version: appVersion
    )

    @Option(
        name: .shortAndLong,
        help: "Root path of your Xcode project. Default is current folder."
    )
    var project: String = "."

    @Flag(
        name: .long,
        help: "Delete the found unused files without asking."
    )
    var force: Bool = false

    @Option(
        name: [.short, .long],
        parsing: .upToNextOption,
        help: "Exclude paths from search."
    )
    var exclude: [String] = []

    @Option(
        name: [.short, .long],
        parsing: .upToNextOption,
        help: "Resource file extensions need to be searched. Default is 'imageset jpg png gif pdf'"
    )
    var resourceExtensions: [String] = ["imageset", "jpg", "png", "gif", "pdf"]

    @Option(
        name: [.short, .long],
        parsing: .upToNextOption,
        help: "In which types of files we should search for resource usage. Default is 'm mm swift xib storyboard plist'"
    )
    var fileExtensions: [String] = ["h", "m", "mm", "swift", "xib", "storyboard", "plist"]

    @Flag(
        name: .long,
        help: "Skip the Project file (.pbxproj) reference cleaning. By skipping it, the project file will be left untouched. You may want to skip ths step if you are trying to build multiple projects with dependency and keep .pbxproj unchanged while compiling."
    )
    var skipProjReference: Bool = false

    @Flag(
        name: .long,
        help: "Print results as xcode warnings and return non zero code if any."
    )
    var xcodeWarnings: Bool = false

    @Flag(
        name: .long,
        help: "List unused files and exit without prompting."
    )
    var listOnly: Bool = false

    func run() throws {
        let fengNiao = FengNiao(
            projectPath: project,
            excludedPaths: exclude,
            resourceExtensions: resourceExtensions,
            searchInFileExtensions: fileExtensions
        )

        let unusedFiles: [FileInfo]
        do {
            print("Searching unused file. This may take a while...")
            unusedFiles = try fengNiao.unusedFiles()
        } catch {
            guard let e = error as? FengNiaoError else {
                print("Unknown Error: \(error)".red.bold)
                throw ExitCode(Self.exitUsage)
            }
            switch e {
            case .noResourceExtension:
                print("You need to specify some resource extensions as search target. Use --resource-extensions to specify.".red.bold)
            case .noFileExtension:
                print("You need to specify some file extensions to search in. Use --file-extensions to specify.".red.bold)
            }
            throw ExitCode(Self.exitUsage)
        }

        if unusedFiles.isEmpty {
            print("😎 Hu, you have no unused resources in path: \(Path(project).absolute()).".green.bold)
            return
        }

        if xcodeWarnings {
            for file in unusedFiles.sorted(by: { $0.size > $1.size }) {
                print("\(file.path.string): warning: Unused resource of size \(file.readableSize)")
            }
            throw ExitCode(Self.exitUnusedResources)
        }

        if listOnly {
            let size = unusedFiles.reduce(0) { $0 + $1.size }.fn_readableSize
            for file in unusedFiles.sorted(by: { $0.size > $1.size }) {
                print("\(file.readableSize) \(file.path.string)")
            }
            print("\(unusedFiles.count) unused files are found. Total Size: \(size)".yellow.bold)
            return
        }

        if !force {
            var result = promptResult(files: unusedFiles)
            while result == .list {
                for file in unusedFiles.sorted(by: { $0.size > $1.size }) {
                    print("\(file.readableSize) \(file.path.string)")
                }
                result = promptResult(files: unusedFiles)
            }

            switch result {
            case .list:
                fatalError()
            case .delete:
                break
            case .ignore:
                print("Ignored. Nothing to do, bye!".green.bold)
                return
            }
        }

        print("Deleting unused files...⚙".bold)

        let (deleted, failed) = FengNiao.delete(unusedFiles)
        guard failed.isEmpty else {
            print("\(unusedFiles.count - failed.count) unused files are deleted. But we encountered some error while deleting these \(failed.count) files:".yellow.bold)
            for (fileInfo, err) in failed {
                print("\(fileInfo.path.string) - \(err.localizedDescription)")
            }
            throw ExitCode(Self.exitUsage)
        }

        print("\(unusedFiles.count) unused files are deleted.".green.bold)

        if !skipProjReference {
            if let children = try? Path(project).absolute().children() {
                print("Now Deleting unused Reference in project.pbxproj...⚙".bold)
                for path in children where path.lastComponent.hasSuffix("xcodeproj") {
                    let pbxproj = path + "project.pbxproj"
                    FengNiao.deleteReference(projectFilePath: pbxproj, deletedFiles: deleted)
                }
                print("Unused Reference deleted successfully.".green.bold)
            }
        }
    }
}
