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
    
    let p: Process
    
    init?(path: String, extensions: [String], excluded: [String]) {
        p = Process()
        p.launchPath = "/usr/bin/find"
        
        guard !extensions.isEmpty else {
            return nil
        }
        
        var args = [String]()
        args.append(path)
        args.append("-type")
        args.append("f")
        
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
        
        let rootPath = Path(path)
        for excludedPath in excluded {
            args.append("-not")
            args.append("-path")
            let path = rootPath + Path(excludedPath)
            guard path.exists else { continue }
            
            if path.isDirectory {
                args.append("\(path.string)/*")
            } else {
                args.append(path.string)
            }
            
        }
        
        p.arguments = args
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
