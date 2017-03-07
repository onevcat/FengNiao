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
    
    static var allTests : [(String, (FileSearchRuleTests) -> () throws -> Void)] {
        return [
            ("testPlainImageSearchRule", testPlainImageSearchRule)
        ]
    }
    
}
