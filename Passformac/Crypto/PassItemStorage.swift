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
}


// A thin wrapper around PassItem allowing it to read and decrypted from disk only when needed
class LazyPassItem : Identifiable {
    var url: URL
    var title: String
    var id = UUID()
    
    init(url: URL, title: String) {
        self.url = url
        self.title = title
    }
    
    private var instance: PassItem? = nil
    
    func get() -> PassItem {
        if instance == nil {
            instance = PassItemStorage().loadPassItem(fromURL: url)
        }
        return instance!
    }
}
