//
//  ExtensionFindProcess.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/8.
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

class ExtensionFindProcess: NSObject {
    
    let p: FNProcess
    
    init?(path: Path, extensions: [String], excluded: [Path]) {
        p = FNProcess()
        p.launchPath = "/usr/bin/find"
        
        guard !extensions.isEmpty else {
            return nil
        }
        
        var args = [String]()
        args.append(path.string)
        
        for (i, ext) in extensions.enumerated() {
            if i == 0 {
                args.append("(")
            } else {
                args.append("-or")
            }
            args.append("-name")
            args.append("*.\(ext)")
            
            if i == extensions.count - 1 {
                args.append(")")
            }
        }
        
        for excludedPath in excluded {
            args.append("-not")
            args.append("-path")
            
            let filePath = path + excludedPath
            guard filePath.exists else { continue }
            
            if filePath.isDirectory {
                args.append("\(filePath.string)/*")
            } else {
                args.append(filePath.string)
            }
            
        }
        
        p.arguments = args
    }
    
    convenience init?(path: String, extensions: [String], excluded: [String]) {
        self.init(path: Path(path), extensions: extensions, excluded: excluded.map { Path($0) })
    }
    
    func execute() -> Set<String> {
        let pipe = Pipe()
        p.standardOutput = pipe
        
        let fileHandler = pipe.fileHandleForReading
        p.launch()
        
        let data = fileHandler.readDataToEndOfFile()
        if let string = String(data: data, encoding: .utf8) {
            return Set(string.components(separatedBy: "\n").dropLast())
        } else {
            return []
        }
    }
}
