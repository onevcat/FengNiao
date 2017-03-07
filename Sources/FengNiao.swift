//
//  FengNiao.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation

enum FileType {
    case header
    case swift
    case objc
    case xib
    
    init?(ext: String) {
        switch ext {
        case "h": self = .header
        case "swift": self = .swift
        case "m", "mm": self = .objc
        case "xib", "storyboard": self = .xib
        default: return nil
        }
    }
    
//    var searchRule: FileSearchRule {
//        switch self {
//        case .header:
//        }
//    }
}

struct FileInfo {
    
}

enum FengNiaoError: Error {
    case noResourceExtension
    case noFileExtension
}

struct FengNiao {
    
    let projectPath: String
    let excludedPaths: [String]
    let resourceExtensions: [String]
    let searchInFileExtensions: [String]
    
    func unusedFiles() throws -> [FileInfo] {
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
        return []
    }
}
