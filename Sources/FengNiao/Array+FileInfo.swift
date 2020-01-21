//
//  Array+FileInfo.swift
//  
//
//  Created by Omar Khaled Gawish on 16/1/20.
//

import FengNiaoKit

extension Array where Element == FileInfo {
    var filesSize: Int {
        return reduce(0) { $0 + $1.size }
    }
}
