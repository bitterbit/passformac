//
//  DirectoryUtils.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation


struct DirectoryUtils {
    
    func getPassItems(at: URL!) -> [PassItem] {
        var items = [PassItem]()
        
        let dir : URL = at!
        do {
            let filemanager = FileManager.default
            let files = try filemanager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for f in files {
                let filename = String(f.lastPathComponent.split(separator: ".")[0])
                items.append(PassItem(title: filename, path: f.absoluteURL))
            }
        } catch { /* do nothing */ }
        
        return items
    }
    
    static func persistPermissionToFolder(for workdir: URL){
        do {
            let bookmarkData = try workdir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "workingDirectoryBookmark") // save in UserDefaults
        } catch {
            print("Failed to save bookmark data for \(workdir)", error)
        }
    }
}
