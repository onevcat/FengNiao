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
    
    var plainFileName: String {
        let path = Path(self)
        var result = path.lastComponentWithoutExtension
        
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

