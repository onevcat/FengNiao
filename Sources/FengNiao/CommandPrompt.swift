//
//  CommandPrompt.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
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
