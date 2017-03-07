//
//  FengNiaoKitSpec.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation
import Spectre
@testable import FengNiaoKit

public func testFengNiaoKit() {
describe("Extensions") {
    $0.it("should parse to plain name") {
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
        let result = paths.map { $0.plainFileName }
        try expect(result) == expected
    }
}
    
describe("Search Rule") {
    $0.it("plain rule with image extensions applies") {
        let searcher = PlainImageSearchRule(extensions: ["png", "jpg"])
        let content = "<h2>Spectacular Mountain</h2>\n<img src=\"public/image/mountain.jpg\" alt=\"Mountain View\" style=\"width:304px;height:228px;\">\n<img src=\"cat.png\">\n<img src=\"dog.svg\">"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["mountain", "cat"]
        try expect(result) == expected
    }
    
    $0.it("plain rule with empty extension applies") {
        let searcher = PlainImageSearchRule(extensions: [])
        let content = "<h2>Spectacular Mountain</h2>\n<img src=\"public/image/mountain.jpg\" alt=\"Mountain View\" style=\"width:304px;height:228px;\">\n<img src=\"cat.png\">\n<img src=\"dog.svg\">"
        let emptyResult = searcher.search(in: content)
        try expect(emptyResult) == []
    }
    
    $0.it("ObjC search rule applies") {
        let searcher = ObjCImageSearchRule()
        let content = "[UIImage imageName:@\"hello\"]\nNSString *imageName = @\"world@2x\"\n[[NSBundle mainBundle] pathForResource:@\"foo/bar/aaa\" ofType:@\"png\"]"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["hello", "world", "aaa", "png"]
        try expect(result) == expected
    }
    
    $0.it("Swift search rule applies") {
        let searcher = SwiftImageSearchRule()
        let content = "UIImage(named: \"button_image\")\nlet s = \"foo.jpg\"\n"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["button_image", "foo"]
        try expect(result) == expected
    }
    
    $0.it("xib search rule applies") {
        let searcher = XibImageSearchRule()
        let content = "<resources>\n<image name=\"btn_error\" width=\"39\" height=\"39\"/>\n<image name=\"disconnect_wifi\" width=\"61\" height=\"49\"/>\n</resources>"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["btn_error", "disconnect_wifi"]
        try expect(result) == expected
    }
}
}
