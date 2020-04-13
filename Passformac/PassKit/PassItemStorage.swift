//
//  PassItemStorage.swift
//  Passformac
//
//  Created by Gal on 13/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation


class PassItemStorage {
    func loadPassItem(fromURL: URL) -> PassItem {
        var passItem = PassItem(title: fromURL.lastPathComponent)
        passItem.unserialize(content: PGPFileReader.shared.loadRawPassItem(at: fromURL))
        return passItem
    }
    
    func savePassItem(atURL: URL, item: PassItem) -> Bool {
        return PGPFileReader.shared.savePassItem(item: item, at: atURL)
    }
    
    func getPassItems(fromURL: URL!) -> [LazyPassItem] {
        var items = [LazyPassItem]()
        
        let dir : URL = fromURL!
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
}
