import Foundation
import CommandLineKit
import Rainbow
import FengNiaoKit
import PathKit

#if os(Linux)
let EX_OK = 0
let EX_USAGE = 64
#endif

let cli = CommandLineKit.CommandLine()
cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error: str = s.red.bold
    case .optionFlag: str = s.green.underline
    default: str = s
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let projectPathOption = StringOption(
    shortFlag: "p", longFlag: "project",
    helpMessage: "Root path of your Xcode project. Default is current folder.")
cli.addOption(projectPathOption)

let isForceOption = BoolOption(
    longFlag: "force",
    helpMessage: "Delete the found unused files without asking.")
cli.addOption(isForceOption)

let excludePathOption = MultiStringOption(
    shortFlag: "e", longFlag: "exclude",
    helpMessage: "Exclude paths from search.")
cli.addOption(excludePathOption)

let resourceExtOption = MultiStringOption(
    shortFlag: "r", longFlag: "resource-extensions",
    helpMessage: "Resource file extensions need to be searched. Default is 'imageset jpg png gif'")
cli.addOption(resourceExtOption)

let fileExtOption = MultiStringOption(
    shortFlag: "f", longFlag: "file-extensions",
    helpMessage: "In which types of files we should search for resource usage. Default is 'm mm swift xib storyboard'")
cli.addOption(fileExtOption)

let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints this help message.")
cli.addOption(helpOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(EX_OK)
}


let projectPath = projectPathOption.value ?? "."
let isForce = isForceOption.value
let excludePaths = excludePathOption.value ?? []
let resourceExtentions = resourceExtOption.value ?? ["imageset", "jpg", "png", "gif"]
let fileExtensions = fileExtOption.value ?? ["m", "mm", "swift", "xib", "storyboard"]

let fengNiao = FengNiao(projectPath: projectPath,
                        excludedPaths: excludePaths,
                        resourceExtensions: resourceExtentions,
                        searchInFileExtensions: fileExtensions)

let unusedFiles: [FileInfo]
do {
    print("Searching unused file. This may take a while...")
    unusedFiles = try fengNiao.unusedFiles()
} catch {
    guard let e = error as? FengNiaoError else {
        print("Unknown Error: \(error)".red.bold)
        exit(EX_USAGE)
    }
    switch e {
    case .noResourceExtension:
        print("You need to specify some resource extensions as search target. Use --resource-extensions to specify.".red.bold)
    case .noFileExtension:
        print("You need to specify some file extensions to search in. Use --file-extensions to specify.".red.bold)
    }
    exit(EX_USAGE)
}

if unusedFiles.isEmpty {
    print("😎 Hu, you have no unused resources in path: \(Path(projectPath).absolute()).".green.bold)
    exit(EX_OK)
}

if !isForce {
    var result = promptResult(files: unusedFiles)
    while result == .list {
        for file in unusedFiles {
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
        exit(EX_OK)
    }
}

print("Deleting unused files...⚙".bold)

let failed = FengNiao.delete(unusedFiles)
if failed.isEmpty {
    print("\(unusedFiles.count) unused files are deleted.".green.bold)
} else {
    print("\(unusedFiles.count - failed.count) unused files are deleted. But we encountered some error while deleting these \(failed.count) files:".yellow.bold)
    for (fileInfo, err) in failed {
        print("\(fileInfo.path.string) - \(err.localizedDescription)")
    }
}






