//
//  FengNiaoKitSpec.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
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

import Foundation
import Spectre
@testable import FengNiaoKit
import  PathKit

public func testFengNiaoKit() {    
describe("FengNiaoKit") {
    let fixtures = Path(#file).parent().parent() + "Fixtures"

    $0.describe("String Extensions") {
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
    
    $0.describe("Int Extesnions") {
        $0.it("should parse for 0 byte") {
            try expect(0.fn_readableSize) == "0 B"
        }
        $0.it("should parse several bytes") {
            try expect(123.fn_readableSize) == "123 B"
        }
        $0.it("should parse serveral kb") {
            try expect(123_456.fn_readableSize) == "123.46 KB"
        }
        $0.it("should parse serveral mb") {
            try expect(123_456_789.fn_readableSize) == "123.46 MB"
        }
        $0.it("should parse serveral gb") {
            try expect(1_123_456_789.fn_readableSize) == "1.12 GB"
        }
        $0.it("should parse more than tb") {
            try expect(1_321_123_456_789.fn_readableSize) == "1321.12 GB"
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
    
    $0.describe("File Info Structure") {
        $0.it("could create a file info struct") {
            let path = fixtures + "FileInfo/file_1_byte"
            let fileInfo = FileInfo(path: path.string)
            
            try expect(fileInfo.path) == path
            try expect(fileInfo.size) == 1
        }
        
        $0.it("could generate readable size text") {
            let rootPath = fixtures + "FileInfo"
            let root = FileInfo(path: rootPath.string)
            try expect(root.readableSize) == "1.23 KB"
            
            let file1BytePath = fixtures + "FileInfo/file_1_byte"
            let file1Byte = FileInfo(path: file1BytePath.string)
            try expect(file1Byte.readableSize) == "1 B"
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
            let expected: [String: Set<String>] = [
                "file1": [(project + "file1.png").string],
                "file2": [(project + "file2.jpg").string],
                "images": [(project + "images.imageset").string]
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
            let expected: [String: Set<String>] = [
                "normal": [(project + "normal.png").string],
                "image": [(project + "Assets.xcassets/image.imageset").string]
            ]
            try expect(result) == expected
        }
        
        $0.it("should not skip same files with difference scale suffix") {
            let project = fixtures + "ResourcesSuffix"
            let fengniao = FengNiao(projectPath: project.string,
                                    excludedPaths: [],
                                    resourceExtensions: ["png"],
                                    searchInFileExtensions: [])
            let result = fengniao.allResourceFiles()
            let expected: [String: Set<String>] = [
                "image": [(project + "image@2x.png").string, (project + "image@3x.png").string],
                "cloud": [(project + "cloud.png").string]
            ]
            try expect(result) == expected
        }
    }
    
    $0.describe("FengNiao File Filter") {
        $0.it("should filter simple unused files") {
            let all: [String: Set<String>] = [
                "face": ["face.png"],
                "book": ["book.png"],
                "moon": ["moon.png"]
            ]
            let used: Set<String> = ["book"]
            
            let result = FengNiao.filterUnused(from: all, used: used)
            let expected: Set<String> = ["face.png", "moon.png"]
            try expect(result) == expected
            
        }
        
        $0.it("should filter same name files correctly") {
            let all: [String: Set<String>] = [
                "face": ["face1.png", "face2.png"],
                "book": ["book.png"],
                "moon": ["moon.png"]
            ]
            let used: Set<String> = ["book"]
            
            let result = FengNiao.filterUnused(from: all, used: used)
            let expected: Set<String> = ["face1.png", "face2.png", "moon.png"]
            try expect(result) == expected
        }
        
        $0.it("should not filter similar pattern") {
            let all: [String: Set<String>] = [
                "face": ["face.png"],
                "image01": ["image01.png"],
                "image02": ["image02.png"],
                "image03": ["image03.png"],
                "1_set": ["001_set.jpg"],
                "2_set": ["002_set.jpg"],
                "3_set": ["003_set.jpg"],
                "middle_01_bird": ["middle_01_bird@2x.png"],
                "middle_02_bird": ["middle_02_bird@2x.png"],
                "middle_03_bird": ["middle_03_bird@2x.png"],
                "suffix_1": ["suffix_1.jpg"],
                "suffix_2": ["suffix_2.jpg"],
                "suffix_3": ["suffix_3.jpg"],
                "unused_1": ["unused_1.png"],
                "unused_2": ["unused_2.png"],
                "unused_3": ["unused_3.png"],
            ]
            let used: Set<String> = ["image%02d", "%d_set", "middle_%d_bird","suffix_"]
            let result = FengNiao.filterUnused(from: all, used: used)
            let expected: Set<String> = ["face.png", "unused_1.png", "unused_2.png", "unused_3.png"]
            try expect(result) == expected
        }
    }
    
    $0.describe("FengNiao Deleting File") {
        
        let file = fixtures + "DeleteFiles/file_in_root"
        let folder = fixtures + "DeleteFiles/Folder"
        
        let fileDes = fixtures + "DeleteFiles/file_in_root_copy"
        let folderDes = fixtures + fixtures + "DeleteFiles/Folder_Copy"
        
        $0.before {
            #if os(macOS)
            try! file.copy(fileDes)
            try! folder.copy(folderDes)
            #endif
        }
        
        $0.after {
            #if os(macOS)
            try? fileDes.delete()
            try? folderDes.delete()
            #endif
        }
        
        $0.it("should delete specified file") {
            #if os(Linux)
            throw skip("Linux copyItem not implemented yet in FileManager.")
            #endif
            
            try expect(fileDes.exists).to.beTrue()
            try expect(folderDes.exists).to.beTrue()
            
            let failed = FengNiao.delete([fileDes, folderDes].map{ FileInfo(path: $0.string) })
            
            try expect(failed.count) == 0
            try expect(fileDes.exists).to.beFalse()
            try expect(folderDes.exists).to.beFalse()
        }
    }
    
    $0.describe("FengNiao Delete the xcodeproj image reference"){
        let file = fixtures+"DeleteReference"
        
        let fileDes = fixtures + "DeleteReferenceCopy"
        $0.before {
            #if os(macOS)
                try! file.copy(fileDes)
            #endif
        }
        
        $0.after {
            #if os(macOS)
                try? fileDes.delete()
            #endif
        }
        $0.it("Remove the Reference"){
            #if os(Linux)
                throw skip("Linux copyItem not implemented yet in FileManager.")
            #endif
            let projectPath = fileDes + "FengNiao.xcodeproj"+"project.pbxproj"
            let fileProjectPath = file + "FengNiao.xcodeproj"+"project.pbxproj"
            let file:String = try! fileProjectPath.read()
            var project:String = try! projectPath.read()
            try expect(file) == project
            let path  = FileInfo(path: "/text/file1.png")
            FengNiao.deletedFiles = [path]
            FengNiao.deleteReference(projectPath: projectPath)
            project = try! projectPath.read()
            try expect(file) != project
            try expect(project.contains("file1.png")) == false
        }
    }

}
}
    
public func == (lhs: Expectation<[String: Set<String>]>, rhs: [String: Set<String>]) throws {
    if let leftDic = try lhs.expression() {
        for (key, value) in leftDic {
            if let rValue = rhs[key], value != rValue {
                throw lhs.failure("\(String(describing: leftDic)) is not equal to \(rhs)")
            }
        }
        
    } else {
        throw lhs.failure("given value is nil")
    }
}



