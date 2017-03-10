//
//  Extensions.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

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
            result = String(describing: result.utf16.dropLast(3))
        }
        return result
    }
    
    func appendingPathComponent(_ str: String) -> String {
        let nsstring = NSString(string: self)
        return nsstring.appendingPathComponent(str)
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
