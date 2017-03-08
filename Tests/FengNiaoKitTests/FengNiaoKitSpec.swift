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
import  PathKit
public func testFengNiaoKit() {
    
describe("FengNiaoKit") {
    let fixtures = Path(#file).parent().parent() + "Fixtures"

    $0.describe("Extensions") {
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
                "file1.swift",
                "file2",
                "file3",
                "file4",
                "file5",
                "file@2x6"
            ]
            let result = paths.map { $0.plainFileName(extensions: ["png", "jpg"]) }
            try expect(result) == expected
        }
    }

    $0.describe("Search Rule") {
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
            let searcher = ObjCImageSearchRule(extensions: [])
            let content = "[UIImage imageName:@\"hello\"]\nNSString *imageName = @\"world@2x\"\n[[NSBundle mainBundle] pathForResource:@\"foo/bar/aaa\" ofType:@\"png\"]"
            let result = searcher.search(in: content)
            let expected: Set<String> = ["hello", "world", "aaa", "png"]
            try expect(result) == expected
        }
        
        $0.it("Swift search rule applies") {
            let searcher = SwiftImageSearchRule(extensions: ["jpg"])
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
    
    $0.describe("Find Process") {
        $0.it("should get proper files") {
            let project = fixtures + "FindProcess"
            let process = ExtensionFindProcess(path: project.string, extensions: ["swift"], excluded: [])
            let result = process?.execute()
            let expected = Set(["Folder1/ignore_ext.swift"].map { (project + $0).string })
            try expect(result) == expected
        }
        
        $0.it("should get proper files with exclude pattern") {
            let project = fixtures + "FindProcess"
            let process = ExtensionFindProcess(path: project.string, extensions: ["png", "jpg"], excluded: ["Folder1/Ignore", "Folder2/ignore_file.jpg"])
            let result = process?.execute()
            let expected = Set(["file1.png", "Folder1/file2.png", "Folder1/SubFolder/file3.jpg", "Folder2/file4.jpg"].map { (project + $0).string })
            try expect(result) == expected
        }
    }
    
    $0.describe("FengNiao Used String Searcher") {
        $0.it("should work for txt file") {
            let project = fixtures + "FileStringSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png", "jpg"],
                                    searchInFileExtensions: ["txt"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["image", "another-image"]
            
            try expect(result) == expected
        }
        
        $0.it("should work for swift file") {
            let project = fixtures + "FileStringSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png", "jpg"],
                                    searchInFileExtensions: ["swift"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["common.login",
                                         "common.logout",
                                         "live_btn_connect",
                                         "live_btn_connect",
                                         "name-key",
                                         "无法支持"]
            
            try expect(result) == expected
        }
        
        $0.it("should work for objc file") {
            let project = fixtures + "FileStringSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png", "jpg"],
                                    searchInFileExtensions: ["m", "mm"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["info.error.memory.full.confirm",
                                         "info.error.memory.full.ios",
                                         "image",
                                         "name-of-mm",
                                         "C",
                                         "image-from-mm"]
            
            try expect(result) == expected
        }
        
        $0.it("should work for xib file") {
            let project = fixtures + "FileStringSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: [],
                                    searchInFileExtensions: ["xib", "storyboard"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["profile_image",
                                         "bottom",
                                         "top",
                                         "left",
                                         "right"]
            
            try expect(result) == expected
        }
        
        $0.it("could search in subfolder") {
            let project = fixtures + "SubFolderSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png", "jpg"],
                                    searchInFileExtensions: ["m", "xib"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["profile_image",
                                         "bottom",
                                         "top",
                                         "info.error.memory.full.confirm",
                                         "info.error.memory.full.ios",
                                         "image"]
            
            try expect(result) == expected
        }
        
        $0.it("could search excluded folder") {
            let project = fixtures + "SubFolderSearcher"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: ["SubFolder2"],
                                    resourceExtensions: ["png", "jpg"],
                                    searchInFileExtensions: ["m", "xib"])
            let result = fengniao.allUsedStringNames()
            let expected: Set<String> = ["info.error.memory.full.confirm",
                                         "info.error.memory.full.ios",
                                         "image"]
            
            try expect(result) == expected
        }
    }
    
    $0.describe("FengNiao Resource Searcher") {
        $0.it("should search resources in a simeple project") {
            let project = fixtures + "SimpleResource"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png", "jpg", "imageset"],
                                    searchInFileExtensions: [])
            let result = fengniao.allResourceFiles()
            let expected = [
                "file1": (project + "file1.png").string,
                "file2": (project + "file2.jpg").string,
                "images": (project + "images.imageset").string
            ]
            try expect(result) == expected
        }
        
        $0.it("should properly skip resource in bundle") {
            let project = fixtures + "ResourcesInBundle"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: ["Ignore"],
                                    resourceExtensions: ["png", "jpg", "imageset"],
                                    searchInFileExtensions: [])
            let result = fengniao.allResourceFiles()
            let expected = [
                "normal": (project + "normal.png").string,
                "image": (project + "Assets.xcassets/image.imageset").string
            ]
            try expect(result) == expected
        }
    }

}
}
    




