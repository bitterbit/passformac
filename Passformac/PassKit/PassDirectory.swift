//
//  DirectoryUtils.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import AppKit

class PassDirectory {
    static func choosePassFolder(_ onDone: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                PassDirectory.persistPermissionToPassFolder(for: panel.url!)
                onDone(panel.url)
            } else {
                onDone(nil)
            }
        }
    }
    
    static func persistPermissionToPassFolder(for workdir: URL){
        do {
            let bookmarkData = try workdir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "workingDirectoryBookmark") // save in UserDefaults
        } catch {
            print("Failed to save bookmark data for \(workdir)", error)
        }
    }
    
    static func getSavedPassFolder() -> URL? {
        do {
            var isStale = false
            let bookmarkData = UserDefaults.standard.data(forKey: "workingDirectoryBookmark")
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
}
