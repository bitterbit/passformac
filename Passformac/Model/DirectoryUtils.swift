//
//  DirectoryUtils.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation


struct DirectoryUtils {
    
    func getPassItems(at: URL!) -> [LazyPassItem] {
        var items = [LazyPassItem]()
        
        let dir : URL = at!
        do {
            let filemanager = FileManager.default
            let files = try filemanager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for f in files {
                let filename = String(f.lastPathComponent.split(separator: ".")[0])
                items.append(LazyPassItem(url: f.absoluteURL, title: filename))
            }
        } catch { /* do nothing */ }
        
        return items
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
