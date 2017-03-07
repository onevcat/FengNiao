//
//  FengNiao.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation

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
    
    var searchRules: [FileSearchRule] {
        switch self {
        case .swift: return [SwiftImageSearchRule()]
        case .objc: return [ObjCImageSearchRule()]
        case .xib: return [XibImageSearchRule()]
        }
    }
}

public struct FileInfo {
    
}

public enum FengNiaoError: Error {
    case noResourceExtension
    case noFileExtension
}

public struct FengNiao {

    let projectPath: String
    let excludedPaths: [String]
    let resourceExtensions: [String]
    let searchInFileExtensions: [String]
    
    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], searchInFileExtensions: [String]) {
        let currentPath = FileManager.default.currentDirectoryPath
        self.projectPath = currentPath.appendingPathComponent(projectPath)
        self.excludedPaths = excludedPaths
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
        

        return [FileInfo()]
    }
    
    func allResourceFiles() -> [String: FileInfo] {
        return [:]
    }
    
    func allUsedFileNames() -> Set<String> {
        
        let allFiles = usedFileNames(atPath: projectPath)
        
        return []
    }
    
    func usedFileNames(atPath path: String, base: String = "") -> Set<String> {
        var result = Set<String>()
        let baseNSString = NSString(string: base)
        guard let allFiles = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            print("Encountered a problem when reading content in \(path)")
            return result
        }
        
        for file in allFiles {
            if file.hasPrefix(".") {
                continue
            }
            
            if excludedPaths.contains(baseNSString.appendingPathComponent(path)) {
                continue
            }
            
            
            
        }
        
        return result
    }
}




