//
//  CommandPrompt.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Swiftline
import Rainbow

public enum Action {
    case list
    case delete
    case ignore
}

public func promptResult(files: [FileInfo]) -> Action {
    print("\(files.count) unused files are found.".yellow)
    let op = ask("Waht do you want to do with them? (l)ist/(d)elete/(i)gnore (Default is 'l')".yellow)
    switch op {
    case "l", "L": return .list
    case "d", "D": return .delete
    case "i", "I": return .ignore
    default: return .list
    }
}
