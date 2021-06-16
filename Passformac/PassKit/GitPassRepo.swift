//
//  GitPassRepo.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectiveGit

enum GitError : String, Error {
    case NoGitRepo =  "No git repo"
    case NoRemoteBranchConfigured = "No remote branch, pull manually from master and try again"
    case NoRemoteConfigured = "No remote configured"
}

extension GitError: LocalizedError {
    var errorDescription: String? {
        return self.rawValue
    }
}

enum ValidationError: Error {
    case InvalidGitDir
}

class GitPassRepo {
    private var repo: GTRepository
    private var remote: GTRemote?
    private var dir: URL
    
    init(_ url: URL) throws {
        if try GitPassRepo.isGitDirValid(url) == false {
            throw ValidationError.InvalidGitDir
        }
        
        self.dir = url
        repo = try GTRepository.init(url: url)
        remote = self.selectRemote()
    }
    
    private static func isGitDirValid(_ dir: URL) throws -> Bool {
        do {
            let s = try String(contentsOfFile: "\(dir.absoluteString).git/HEAD")
            return s.count > 0;
        } catch {
            return false;
        }
    }
    
    func getDirectory() -> URL {
        return dir
    }
    
    func getRemoteAddress() -> String? {
        return remote?.urlString ?? nil
    }
    
    func getRemoteName() -> String? {
        return remote?.name ?? nil
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
    
    func sync(onNeedPassword: @escaping GitNeedPasswordCallback) -> Error? {
        let onCredsNeededAdapter = { (type: GTCredentialType, url: String, username: String) -> GTCredential? in
            guard let (username, password) = onNeedPassword() as? (String, String) else {
                return nil
            }
            do { return try GTCredential.init(userName: username, password: password) } catch {
                print("error while asking for creds from user. err: \(error)")
            }
            return nil
        }
        
        let options : [AnyHashable: Any] = [
            GTRepositoryRemoteOptionsCredentialProvider: GTCredentialProvider.init(block: onCredsNeededAdapter)
        ]
        
        do {
            // TODO better implement progress.
            // but is it possible? https://github.com/libgit2/libgit2/issues/4654 https://github.com/libgit2/libgit2/issues/1054
            let progressPull : (UnsafePointer<git_transfer_progress>, UnsafeMutablePointer<ObjCBool>) -> Void = { a, b in
                print("git pull progress:...")
            }
            
            let progressPush : (UInt32, UInt32, Int, UnsafeMutablePointer<ObjCBool>) -> Void  = { a, b, c, d in
                print("git push progress: \(a), \(b) \(c) \(d)")
            }
            
            
            guard let remote = self.remote else {
                return GitError.NoRemoteConfigured
            }
            
            print("getting branches")
            
            
            
            let branches = try repo.remoteBranches()
            
            if branches.count == 0 {
                print("fetching frome remote \(remote)")
                try repo.fetch(remote, withOptions: [AnyHashable: Any](), progress: nil)
            }
            
            print("choosing branch")
            guard let branch = try repo.remoteBranches().first else {
                return GitError.NoRemoteBranchConfigured
            }
            
            if repo.isHEADUnborn {
                print("HEAD is Unborn but we have remote branches, try and checkout a branch")
                try repo.fetch(remote, withOptions: [AnyHashable: Any](), progress: nil)
                let block : (String, UInt, UInt) -> Void = { _,_,_ in print("xxx") }
                let checkoutOptions = GTCheckoutOptions(strategy: .force, progressBlock: block)
                let localBranch = try repo.createBranchNamed(branch.shortName!, from: branch.oid!, message: nil)
                try repo.checkoutReference(localBranch.reference, options: checkoutOptions)
                
            }
           
            print("started pulling from branch: \(branch) remote: \(remote)")
            try repo.pull(branch, from: remote, withOptions: options, progress: progressPull)
            print("started pushing")
            try repo.push(branch, to: remote, withOptions: options, progress: progressPush)
            print("done sync")
        } catch {
            print("got error while syncing git \(error)")
            return error
        }
        // all is good, return no error
        return nil
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
    
    func selectRemote() -> GTRemote? {
        guard let conf = try? repo.configuration() else {
            return nil
        }
        
        guard let remotes = conf.remotes else {
            return nil
        }
        
        for remote in remotes {
            if isRemoteSupported(remote) {
                return remote
            }
        }
        
        return nil
    }
    
    private func isRemoteSupported(_ remote: GTRemote) -> Bool {
        return remote.urlString?.starts(with: "http") ?? false
    }
}
