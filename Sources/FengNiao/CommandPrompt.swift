//
//  CommandPrompt.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Swiftline
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
    return choose("What do you want to do with them? ".bold, type: Action.self) { settings in
        settings.addChoice("list") { .list }
        settings.addChoice("delete") { .delete}
        settings.addChoice("ignore") { .ignore}
    }
}
