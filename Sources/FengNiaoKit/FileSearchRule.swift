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
    var patterns: [String] { get }
}

extension RegPatternSearchRule {
    func search(in content: String) -> Set<String> {
        
        let nsstring = NSString(string: content)
        var result = Set<String>()
        
        for pattern in patterns {
            let reg = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            let matches = reg.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                let extracted = nsstring.substring(with: checkingResult.rangeAt(1))
                result.insert(extracted.plainFileName)
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
    let patterns = ["@\"(.+?)\""]
}

struct SwiftImageSearchRule: RegPatternSearchRule {
    let patterns = ["\"(.+?)\""]
}

struct XibImageSearchRule: RegPatternSearchRule {
    let patterns = ["image name=\"(.+?)\""]
}
