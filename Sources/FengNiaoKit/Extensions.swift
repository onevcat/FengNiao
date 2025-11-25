//
//  Extensions.swift
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
import PathKit

extension String {
    var fullRange: NSRange {
        let nsstring = NSString(string: self)
        return NSMakeRange(0, nsstring.length)
    }
    
    func plainFileName(extensions: [String]) -> String {
        let p = Path(self)
        var result: String!
        for ext in extensions {
            if hasSuffix(".\(ext)") {
                result = p.lastComponentWithoutExtension
                break
            }
        }
        
        if result == nil {
            result = p.lastComponent
        }
        
        if result.hasSuffix("@2x") || result.hasSuffix("@3x") {
            let endIndex = result.index(result.endIndex, offsetBy: -3)
            result = String(result[..<endIndex])
        }
        return result
    }
    
    func appendingPathComponent(_ str: String) -> String {
        let nsstring = NSString(string: self)
        return nsstring.appendingPathComponent(str)
    }
    
    /// Convert resource name (snake/kebab case) to generated Swift asset symbol such as `.icChatWhite`.
    var generatedAssetSymbolKey: String {
        if isEmpty { return "." }
        var ret = "."
        var shouldUpperNext = false
        for character in self {
            switch character {
            case "-", "_", " ":
                shouldUpperNext = true
            default:
                if shouldUpperNext {
                    ret.append(String(character).uppercased())
                    shouldUpperNext = false
                } else {
                    ret.append(character)
                }
            }
        }
        return ret
    }
}

let fileSizeSuffix = ["B", "KB", "MB", "GB"]
extension Int {
    public var fn_readableSize: String {
        var level = 0
        var num = Float(self)
        while num > 1000 && level < 3 {
            num = num / 1000.0
            level += 1
        }
        
        if level == 0 {
            return "\(Int(num)) \(fileSizeSuffix[level])"
        } else {
            return String(format: "%.2f \(fileSizeSuffix[level])", num)
        }
    }
}
