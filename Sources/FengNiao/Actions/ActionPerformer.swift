//
//  ActionPerformer.swift
//  FengNiao
//
//  Created by Omar Khaled Gawish on 16/1/20.
//

import FengNiaoKit
import Rainbow
import PathKit

class ActionPerformer {
    private let unusedFiles: [FileInfo]
    private let projectPath: String
    private let skipProjRefereceCleanOption: Bool
    
    init(unusedFiles: [FileInfo], projectPath: String, skipProjRefereceCleanOption: Bool) {
        self.unusedFiles = unusedFiles
        self.projectPath = projectPath
        self.skipProjRefereceCleanOption = skipProjRefereceCleanOption
    }
    
    func perform(action: Action) {
        switch action {
        case .list: performList()
        case .delete: performDelete()
        case .ignore: break
        }
    }
    
    private func performList() {
        for file in unusedFiles.sorted(by: { $0.size > $1.size }) {
            print("\(file.readableSize) \(file.path.string)")
        }
    }
    
    private func performDelete() {
        print("Deleting unused files...⚙".bold)

        let (deleted, failed) = FengNiao.delete(unusedFiles)
        guard failed.isEmpty else {
            print("\(unusedFiles.count - failed.count) unused files are deleted. But we encountered some error while deleting these \(failed.count) files:".yellow.bold)
            for (fileInfo, err) in failed {
                print("\(fileInfo.path.string) - \(err.localizedDescription)")
            }
            return
            //exit(EX_USAGE)
        }


        print("\(unusedFiles.count) unused files are deleted.".green.bold)

        if !skipProjRefereceCleanOption {
            if let children = try? Path(projectPath).absolute().children(){
                print("Now Deleting unused Reference in project.pbxproj...⚙".bold)
                for path in children {
                    if path.lastComponent.hasSuffix("xcodeproj"){
                        let pbxproj = path + "project.pbxproj"
                        FengNiao.deleteReference(projectFilePath: pbxproj, deletedFiles: deleted)
                    }
                }
                print("Unused Reference deleted successfully.".green.bold)
            }
        }
    }
}
