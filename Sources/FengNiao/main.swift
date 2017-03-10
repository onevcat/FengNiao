import Darwin
import CommandLineKit
import Rainbow
import FengNiaoKit

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

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
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
        print("Unknown Error: \(error)".red)
        exit(EX_USAGE)
    }
    switch e {
    case .noResourceExtension:
        print("You need to specify some resource extensions as search target. Use --resource-extensions to specify.".red)
    case .noFileExtension:
        print("You need to specify some file extensions to search in. Use --file-extensions to specify.".red)
    }
    exit(EX_USAGE)
}

if unusedFiles.isEmpty {
    print("Hu, you have no unused resources in path: \(projectPath)! Good job! 😎".green)
    exit(EX_OK)
}


var result = promptResult(files: unusedFiles)
while result == .list {
    result = promptResult(files: unusedFiles)
}

switch result {
case .list:
    fatalError()
case .delete:
    print("Deleting unused files...⚙")
    print("\(unusedFiles.count) unused files are deleted.".green)
case .ignore:
    print("Ignored. Nothing to do, bye!".green)
}







