//
//  FileSearchRuleTests.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import XCTest
@testable import FengNiaoKit

class FileSearchRuleTests: XCTestCase {
    
    func testPlainImageSearchRule() {
        let searcher = PlainImageSearchRule(extensions: ["png", "jpg"])
        let content = "<h2>Spectacular Mountain</h2>\n<img src=\"public/image/mountain.jpg\" alt=\"Mountain View\" style=\"width:304px;height:228px;\">\n<img src=\"cat.png\">\n<img src=\"dog.svg\">"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["mountain", "cat"]
        
        XCTAssertEqual(result, expected)
        
        let emptySearcher = PlainImageSearchRule(extensions: [])
        let emptyResult = emptySearcher.search(in: content)
        XCTAssertTrue(emptyResult.isEmpty)
    }
    
    func testObjCImageSearchRule() {
        let searcher = ObjCImageSearchRule()
        let content = "[UIImage imageName:@\"hello\"]\nNSString *imageName = @\"world@2x\"\n[[NSBundle mainBundle] pathForResource:@\"foo/bar/aaa\" ofType:@\"png\"]"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["hello", "world", "aaa", "png"]
        
        XCTAssertEqual(result, expected)
    }
    
    func testSwiftImageSearchRule() {
        let searcher = SwiftImageSearchRule()
        let content = "UIImage(named: \"button_image\")\nlet s = \"foo.jpg\"\n"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["button_image", "foo"]
        
        XCTAssertEqual(result, expected)
    }
    
    func testXibImageSearchRule() {
        let searcher = XibImageSearchRule()
        let content = "<resources>\n<image name=\"btn_error\" width=\"39\" height=\"39\"/>\n<image name=\"disconnect_wifi\" width=\"61\" height=\"49\"/>\n</resources>"
        let result = searcher.search(in: content)
        let expected: Set<String> = ["btn_error", "disconnect_wifi"]
        
        XCTAssertEqual(result, expected)
    }
    
    static var allTests : [(String, (FileSearchRuleTests) -> () throws -> Void)] {
        return [
            ("testPlainImageSearchRule", testPlainImageSearchRule),
            ("testObjCImageSearchRule", testObjCImageSearchRule)
        ]
    }
    
}
