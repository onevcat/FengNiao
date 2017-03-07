//
//  ExtensionsTests.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import XCTest
import FengNiao

class ExtensionsTests: XCTestCase {
    
    func testStringPlainName() {
        let paths = [
            "/usr/bin/hello/file1.swift",
            "/foo/file2.png",
            "/foo/file3@2x.jpg",
            "file4@3x.jpg",
            "bar/good/file5",
            "../bar/good/file@2x6@3x.png",
        ]
        let expected = [
            "file1",
            "file2",
            "file3",
            "file4",
            "file5",
            "file@2x6"
        ]
        
        let a = "hello".plainFileName
        print(a)
        
//        let result = paths.map { NSString(string: $0).plainFileName }
        
    }
    
    static var allTests : [(String, (ExtensionsTests) -> () throws -> Void)] {
        return [
            ("testStringStripingSuffix", testStringPlainName)
        ]
    }
    
}
