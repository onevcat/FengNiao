//
//  FileSearchRule.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
            let reg = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            let matches = reg.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                let extracted = nsstring.substring(with: checkingResult.range(at: 1))
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
        return ["\"(.+?)\\.(\(joinedExt))\""]
    }
}

struct ObjCImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["@\"(.*?)\"", "\"(.*?)\""]
}

struct SwiftImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["\"(.*?)\"", "R.image.(.*?)\\(\\)"]
}

struct XibImageSearchRule: RegPatternSearchRule {
    let extensions = [String]()
    let patterns = ["image name=\"(.*?)\"", "image=\"(.*?)\"", "value=\"(.*?)\""]
}

struct PlistImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["<key>UIApplicationShortcutItemIconFile</key>[^<]*<string>(.*?)</string>"]
}

struct PlistAppIconSearchRule: FileSearchRule {
    let extensions: [String]
    
    func search(in content: String) -> Set<String> {
        var result = Set<String>()
        
        let groupRegexStr = "<key>CFBundleIconFiles</key>[^<]*<array>([\\w\\W]*?)</array>"
        let groupRegex = try! NSRegularExpression(pattern: groupRegexStr, options: .caseInsensitive)
        
        let groupMatches = groupRegex.matches(in: content, options: [], range: content.fullRange)
        var groupContents = [String]()
        for checkingResult in groupMatches {
            if let range = Range(checkingResult.range(at: 1), in: content) {
                let extracted = String(content[range])
                groupContents.append(extracted)
            }
        }
        
        guard groupContents.count > 0 else {
            return []
        }
        
        let itemRegexStr = "<string>(.*?)</string>"
        let itemRegex = try! NSRegularExpression(pattern: itemRegexStr, options: .caseInsensitive)
        for itemContent in groupContents {
            let itemMatches = itemRegex.matches(in: itemContent, options: [], range: itemContent.fullRange)
            
            for checkingResult in itemMatches {
                if let range = Range(checkingResult.range(at: 1), in: itemContent) {
                    let extracted = String(itemContent[range])
                    result.insert(extracted.plainFileName(extensions: extensions))
                }
            }
        }
        
        return result
    }
}

struct PbxprojImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["ASSETCATALOG_COMPILER_APPICON_NAME = \"?(.*?)\"?;", "ASSETCATALOG_COMPILER_COMPLICATION_NAME = \"?(.*?)\"?;"]
}

