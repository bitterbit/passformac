//
//  PassItemStorage.swift
//  Passformac
//
//  Created by Gal on 13/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation


class PassItemStorage {
    
    private var git : GitPassRepo?
    
    init(_ root: URL) throws {
        git = try GitPassRepo(root)
    }
    
    func loadPassItem(fromURL: URL) -> PassItem {
        let title = fromURL.deletingPathExtension().lastPathComponent
        var passItem = PassItem(title: title)
        passItem.unserialize(content: PGPFileReader.shared.loadRawPassItem(at: fromURL))
        return passItem
    }
    
    func syncRemote(passwordCallback: @escaping GitNeedPasswordCallback) -> Error? {
        if git != nil {
            return git!.sync(onNeedPassword: passwordCallback)
        }
        
        return GitError.NoGitRepo
    }
    
    func savePassItem(atURL: URL, item: PassItem) -> Bool {
        let filename = getItemTitleForURL(atURL, baseURL: git!.getDirectory())
        
        if !PGPFileReader.shared.savePassItem(item: item, at: atURL) {
            return false
        }
        
        let g = git!
        if !g.commitFile(filename) {
            return false
        }
        
        return true
    }
    
    func getPassItems(fromURL: URL!) -> [LazyPassItem] {
        var items = [LazyPassItem]()
        
        let dir : URL = fromURL!
        do {
            let filemanager = FileManager.default
            
            guard let files = filemanager.enumerator(at: dir, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return [LazyPassItem]() }
            
            for case let f as URL in files {
                let fileAttributes = try f.resourceValues(forKeys:[.isRegularFileKey])
                let title = String(getItemTitleForURL(f, baseURL: dir).split(separator: ".")[0])
                if  fileAttributes.isRegularFile! {
                    items.append(LazyPassItem(
                        url: f.absoluteURL,
                        title: title,
                        passItemStorage: self)
                    )
                }
            }
        } catch { /* do nothing */ }
        
        return items
    }
    
    
    private func getItemTitleForURL(_ url:URL, baseURL: URL) -> String {
        let baseComponents = baseURL.pathComponents
        let urlComponents = url.pathComponents
        
        var lastMutualIndex = -1
        
        for i in 0..<min(urlComponents.count, baseComponents.count) {
            if baseComponents[i] == urlComponents[i] {
                lastMutualIndex = i
            }
        }
        
        if lastMutualIndex == -1 || lastMutualIndex+1 >= urlComponents.count {
            return url.lastPathComponent
        }
        
        return urlComponents.dropFirst(lastMutualIndex+1).joined(separator: "/")
    }
}
