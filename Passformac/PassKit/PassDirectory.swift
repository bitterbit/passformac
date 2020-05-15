//
//  DirectoryUtils.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

class PassDirectory {
    static var shared: PassDirectory = PassDirectory()
    
    let DIR_KEY = "workingDirectoryBookmark"
    
    func validateGitDirectory(_ url: URL) -> Bool {
        do {
            _ = try GitRepoCreator.initFromLocalFolder(url)
        } catch {
            print("error in init git from local folder. error: \(error)")
            return false
        }
        return true
    }
    
    func promptSelectPassDirectory(_ onDone: @escaping (URL?) -> Void) {
        Directory.selectDirectory() { url in
            if url == nil {
                onDone(nil)
                return
            }
            
            if self.validateGitDirectory(url!) {
                self.persistPermissionToPassDirectory(url!)
                onDone(url)
                return
            }
            
            onDone(nil)
            return
        }
    }
    
    func selectPassDirectory(_ url: URL) -> Bool {
        if self.validateGitDirectory(url) {
            self.persistPermissionToPassDirectory(url)
            return true
        }
        return false
    }
    
    private func persistPermissionToPassDirectory(_ workdir: URL){
        do {
            let bookmarkData = try workdir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: DIR_KEY) // save in UserDefaults
        } catch {
            print("Failed to save bookmark data for \(workdir)", error)
        }
    }
    
    func getSavedPassFolder() -> URL? {
        do {
            var isStale = false
            let bookmarkData = UserDefaults.standard.data(forKey: DIR_KEY)
            if bookmarkData == nil {
                return nil
            }
            
            let url = try URL(resolvingBookmarkData: bookmarkData!, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                return nil
            }
            
            // check if we are granted permission
            if !url.startAccessingSecurityScopedResource() {
                return nil
            }
            
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    func resetSavedPassDirectory() {
        UserDefaults.standard.removeObject(forKey: DIR_KEY)
    }
}
