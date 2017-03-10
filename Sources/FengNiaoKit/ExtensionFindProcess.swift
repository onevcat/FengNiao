//
//  ExtensionFindProcess.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/8.
//
//

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
