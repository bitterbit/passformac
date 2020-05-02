//
//  GitPassRepo.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectiveGit


class GitPassRepo {
    private var repo : GTRepository
    private var dir: URL
    
    init(_ url: URL) throws {
        self.dir = url
        repo = try GTRepository.init(url: url)
    }
    
    func getDirectory() -> URL {
        return dir
    }
    
    func commitFile(_ filename: String) -> Bool {
        do {
            try createMasterIfMissing()
            let branch = try repo.currentBranch()
            let last = try? branch.targetCommit()
            let parents = [last]
            let index = try repo.index()
            try index.addFile(filename)
            try index.write()
            let subtree = try index.writeTree()
             _ = try repo.createCommit(with: subtree, message: "Updated \(filename)", parents: parents as? [GTCommit], updatingReferenceNamed: branch.reference.name)
        } catch {
            print("error while git commit. error: \(error)")
            return false
        }
        
        return true
    }
    
    private func createMasterIfMissing() throws {
        if repo.isHEADUnborn {
           let builder = try! GTTreeBuilder(tree: nil, repository: repo)
           try builder.addEntry(with: "initial".data(using: String.Encoding.utf8)!, fileName: "initial", fileMode: .blob)
           let tree = try! builder.writeTree()
           try repo.createCommit(with: tree, message: "initial commit", parents: nil, updatingReferenceNamed: "HEAD")
        }
    }
    
    func sync() {
        
    }
    
    func getAllChangedFiles() -> ([String], [String]) {
        var newFiles: [String] = []
        var modifiedFiles: [String] = []
        do {
            try repo.enumerateFileStatus(options: nil, usingBlock: { (delta1, delta2, val) in
                if delta2?.status != .unmodified || delta1?.status != .unmodified {
                    let path = delta2?.newFile?.path
                    if path != nil {
                        modifiedFiles.append(path!)
                    }
                } else {
                    let path = delta1?.newFile?.path
                    if path != nil {
                        newFiles.append(path!)
                    }
                }
            })
        }
        catch {
            return ([], [])
        }
        
        return (newFiles, modifiedFiles)
    }
}
