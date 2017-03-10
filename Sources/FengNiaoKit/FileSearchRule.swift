//
//  FileSearchRule.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation

protocol FileSearchRule {
    func search(in cotnent: String) -> Set<String>
}

protocol RegPatternSearchRule: FileSearchRule {
    var extensions: [String] { get }
    var patterns: [String] { get }
}

extension RegPatternSearchRule {
    func search(in content: String) -> Set<String> {
        
        let nsstring = NSString(string: content)
        var result = Set<String>()
        
        for pattern in patterns {
            let reg = try! FNRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            let matches = reg.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                #if os(Linux)
                let extracted = nsstring.substring(with: checkingResult.range(at: 1))
                #else
                let extracted = nsstring.substring(with: checkingResult.rangeAt(1))
                #endif
                result.insert(extracted.plainFileName(extensions: extensions) )
            }
        }
        
        return result
    }
}

struct PlainImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    var patterns: [String] {
        if extensions.isEmpty {
            return []
        }
        
        let joinedExt = extensions.joined(separator: "|")
        return ["([a-zA-Z0-9_-]+)\\.(\(joinedExt))"]
    }
}

struct ObjCImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["@\"(.+?)\"", "\"(.+?)\""]
}

struct SwiftImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["\"(.+?)\""]
}

struct XibImageSearchRule: RegPatternSearchRule {
    let extensions = [String]()
    let patterns = ["image name=\"(.+?)\""]
}
