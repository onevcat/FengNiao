//
//  FengNiao.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation
import PathKit
import Rainbow

#if os(Linux)
typealias FNRegularExpression = RegularExpression
typealias FNProcess = NSTask
#else
typealias FNRegularExpression = NSRegularExpression
typealias FNProcess = Process
#endif

enum FileType {
    case swift
    case objc
    case xib
    
    init?(ext: String) {
        switch ext {
        case "swift": self = .swift
        case "m", "mm": self = .objc
        case "xib", "storyboard": self = .xib
        default: return nil
        }
    }
    
    func searchRules(extensions: [String]) -> [FileSearchRule] {
        switch self {
        case .swift: return [SwiftImageSearchRule(extensions: extensions)]
        case .objc: return [ObjCImageSearchRule(extensions: extensions)]
        case .xib: return [XibImageSearchRule()]
        }
    }
}

public struct FileInfo {
    public let path: Path
    public let size: Int
    
    init(path: String) {
        self.path = Path(path)
        self.size = self.path.size
    }
    
    public var readableSize: String {
        return size.fn_readableSize
    }
}

extension Path {
    var size: Int {
        if isDirectory {
            let childrenPaths = try? children()
            return (childrenPaths ?? []).reduce(0) { $0 + $1.size }
        } else {
            // Skip hidden files
            if lastComponent.hasPrefix(".") { return 0 }
            let attr = try? FileManager.default.attributesOfItem(atPath: absolute().string)
            return attr?[.size] as? Int ?? 0
        }
    }
}

public enum FengNiaoError: Error {
    case noResourceExtension
    case noFileExtension
}

public struct FengNiao {

    let projectPath: Path
    let excludedPaths: [Path]
    let resourceExtensions: [String]
    let searchInFileExtensions: [String]
    
    let regularDirExtensions = ["imageset", "launchimage", "appiconset", "bundle"]
    var nonDirExtensions: [String] {
        return resourceExtensions.filter { !regularDirExtensions.contains($0) }
    }
    
    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], searchInFileExtensions: [String]) {
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludedPaths = excludedPaths.map { path + Path($0) }
        self.resourceExtensions = resourceExtensions
        self.searchInFileExtensions = searchInFileExtensions
    }
    
    public func unusedFiles() throws -> [FileInfo] {
        guard !resourceExtensions.isEmpty else {
            throw FengNiaoError.noResourceExtension
        }
        guard !searchInFileExtensions.isEmpty else {
            throw FengNiaoError.noFileExtension
        }

        let allResources = allResourceFiles()
        let usedNames = allUsedStringNames()
        
        return FengNiao.filterUnused(from: allResources, used: usedNames).map( FileInfo.init )
    }
    
    // Return a failed list of deleting
    static public func delete(_ unusedFiles: [FileInfo]) -> [(FileInfo, Error)] {
        var failed = [(FileInfo, Error)]()
        for file in unusedFiles {
            do {
                try file.path.delete()
            } catch {
                failed.append((file, error))
            }
        }
        return failed
    }
    
    func allResourceFiles() -> [String: String] {
        let find = ExtensionFindProcess(path: projectPath, extensions: resourceExtensions, excluded: excludedPaths)
        guard let result = find?.execute() else {
            print("Resource finding failed.".red)
            return [:]
        }
        
        var files = [String: String]()
        fileLoop: for file in result {
            
            // Skip resources in a bundle
            let dirPaths = regularDirExtensions.map { ".\($0)/" }
            for dir in dirPaths where file.contains(dir) {
                continue fileLoop
            }
            
            // Skip the extensions should not be folder
            let filePath = Path(file)
            if let ext = filePath.extension, filePath.isDirectory && nonDirExtensions.contains(ext)  {
                continue
            }
            
            let key = file.plainFileName(extensions: resourceExtensions)
            if let existing = files[key] {
                print("Found a dulplicated file key: \(key). Conflicting name: '\(existing)' | '\(file)'. Consider to rename one of them or exclude one.".yellow)
                continue
            }

            files[key] = file
        }
        return files
    }
    
    func allUsedStringNames() -> Set<String> {
        return usedStringNames(at: projectPath)
    }
    
    func usedStringNames(at path: Path) -> Set<String> {
        guard let subPaths = try? path.children() else {
            print("Failed to get contents in path: \(path)".red)
            return []
        }
        
        var result = [String]()
        for subPath in subPaths {
            if subPath.lastComponent.hasPrefix(".") {
                continue
            }
            
            if excludedPaths.contains(subPath) {
                continue
            }
            
            if subPath.isDirectory {
                result.append(contentsOf: usedStringNames(at: subPath))
            } else {
                let fileExt = subPath.extension ?? ""
                guard searchInFileExtensions.contains(fileExt) else {
                    continue
                }
                
                let fileType = FileType(ext: fileExt)
                
                let searchRules = fileType?.searchRules(extensions: resourceExtensions) ??
                                  [PlainImageSearchRule(extensions: resourceExtensions)]
                
                let content = (try? subPath.read()) ?? ""
                result.append(contentsOf: searchRules.flatMap { $0.search(in: content) })
            }
        }
        
        return Set(result)
    }
    
    static func filterUnused(from all: [String: String], used: Set<String>) -> Set<String> {
        let unusedPairs = all.filter { key, _ in
            return !used.contains(key) &&
                   !used.contains { $0.similarPatternWithNumberIndex(other: key) }
        }
        return Set( unusedPairs.map { $0.value } )
    }
}

let digitalRex = try! FNRegularExpression(pattern: "(\\d+)", options: .caseInsensitive)
extension String {
    
    func similarPatternWithNumberIndex(other: String) -> Bool {
        // self -> pattern "image%02d"
        // other -> name "image01"
        let matches = digitalRex.matches(in: other, options: [], range: other.fullRange)
        // No digital found in resource key.
        guard matches.count >= 1 else { return false }
        let lastMatch = matches.last!
        let digitalRange = lastMatch.rangeAt(1)
        
        var prefix: String?
        var suffix: String?

        let digitalLocation = digitalRange.location
        if digitalLocation != 0 {
            let index = other.index(other.startIndex, offsetBy: digitalLocation)
            prefix = other.substring(to: index)
        }
        
        let digitalMaxRange = NSMaxRange(digitalRange)
        if digitalMaxRange < other.utf16.count {
            let index = other.index(other.startIndex, offsetBy: digitalMaxRange)
            suffix = other.substring(from: index)
        }
        
        switch (prefix, suffix) {
        case (nil, nil):
            return false // only digital
        case (let p?, let s?):
            return hasPrefix(p) && hasSuffix(s)
        case (let p?, nil):
            return hasPrefix(p)
        case (nil, let s?):
            return hasSuffix(s)
        }
    }
}



