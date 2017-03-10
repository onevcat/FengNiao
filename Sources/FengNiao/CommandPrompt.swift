//
//  CommandPrompt.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Rainbow
import FengNiaoKit

public enum Action {
    case list
    case delete
    case ignore
}

public func promptResult(files: [FileInfo]) -> Action {
    let size = files.reduce(0) { $0 + $1.size }.fn_readableSize
    print("\(files.count) unused files are found. Total Size: \(size)".yellow.bold)
    print("What do you want to do with them? (l)ist|(d)elete|(i)gnore".bold, terminator: " ")
    
    guard let result = readLine() else {
        return promptResult(files: files)
    }
    switch result {
    case "l", "L": return .list
    case "d", "D": return .delete
    case "i", "I": return .ignore
    default: return promptResult(files: files)
    }
}
