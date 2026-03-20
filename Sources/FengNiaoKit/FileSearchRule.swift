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
    func search(in content: String) -> Set<String>
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
    let patterns = ["\"(.*?)\""]
}

/// Search for member access patterns like `.icFlag` or `UIImage.icFlag` that Xcode generates for assets.
/// Also handles nested member access patterns like `Image(.Icons.Settings.logo)` that Xcode
/// generates for asset catalog folders.
struct SwiftMemberAccessSearchRule: FileSearchRule {
    func search(in content: String) -> Set<String> {
        let nsstring = NSString(string: content)
        var result = Set<String>()
        var nestedSymbolRanges: [NSRange] = []

        // Pattern 1: Nested member access like `Image(.Icons.Settings.logo)`
        // Process this first and track their ranges to exclude them from simple pattern matching
        let nestedPattern = #"(?:Image|UIImage|NSImage|Color|UIColor|NSColor)\s*\(\s*\.([A-Za-z0-9_.]+)\s*\)"#
        let nestedReg = try! NSRegularExpression(pattern: nestedPattern, options: [])
        let nestedMatches = nestedReg.matches(in: content, options: [], range: content.fullRange)
        for match in nestedMatches {
            let chainRange = match.range(at: 1)
            guard chainRange.location != NSNotFound else { continue }
            let chain = nsstring.substring(with: chainRange)
            result.insert(".\(chain)")

            // Track the full range of this nested pattern to exclude from simple matching
            nestedSymbolRanges.append(match.range)
        }

        // Pattern 1b: ImageResource member access like `ImageResource.homeIcon` or `ImageResource.Icons.Settings.logo`
        // This is similar to nested but without parentheses
        let imageResourcePattern = #"ImageResource\s*\.([A-Za-z0-9_.]+)"#
        let imageResourceReg = try! NSRegularExpression(pattern: imageResourcePattern, options: [])
        let imageResourceMatches = imageResourceReg.matches(in: content, options: [], range: content.fullRange)
        for match in imageResourceMatches {
            let chainRange = match.range(at: 1)
            guard chainRange.location != NSNotFound else { continue }
            let chain = nsstring.substring(with: chainRange)
            result.insert(".\(chain)")

            // Track the full range to exclude from simple matching
            nestedSymbolRanges.append(match.range)
        }

        // Pattern 2: Simple member access like `UIImage.icFlag` or `.icFlagHighlighted`
        // Only match if not inside a nested Image(...) construct
        let simplePattern = #"(?<![A-Za-z0-9_])(UIImage|UIColor|NSImage|NSColor|Image|Color)?\s*\.\s*([A-Za-z0-9_]+)"#
        let simpleReg = try! NSRegularExpression(pattern: simplePattern, options: [])
        let simpleMatches = simpleReg.matches(in: content, options: [], range: content.fullRange)

        for match in simpleMatches {
            // Skip if this match is inside a nested pattern
            let matchRange = match.range
            var isInsideNested = false
            for nestedRange in nestedSymbolRanges {
                if NSLocationInRange(matchRange.location, nestedRange) {
                    isInsideNested = true
                    break
                }
            }

            guard !isInsideNested else { continue }

            let identifierRange = match.range(at: 2)
            guard identifierRange.location != NSNotFound else { continue }
            let identifier = nsstring.substring(with: identifierRange)
            result.insert(".\(identifier)")
        }

        return result
    }
}

struct XibImageSearchRule: RegPatternSearchRule {
    let extensions = [String]()
    let patterns = ["image name=\"(.*?)\"", "image=\"(.*?)\"", "value=\"(.*?)\""]
}

struct PlistImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["<string>(.*?)</string>"]
}

struct PbxprojImageSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["ASSETCATALOG_COMPILER_APPICON_NAME = \"?(.*?)\"?;", "ASSETCATALOG_COMPILER_COMPLICATION_NAME = \"?(.*?)\"?;"]
}
