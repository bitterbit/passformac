//
//  LazyPassItem.swift
//  Passformac
//
//  Created by Gal on 13/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

// A thin wrapper around PassItem allowing it to read and decrypted from disk only when needed
class LazyPassItem : Identifiable {
    var url: URL
    var title: String
    var id = UUID()
    
    init(url: URL, title: String) {
        self.url = url
        self.title = title.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespaces)
    }
    
    private var instance: PassItem? = nil
    
    func get() -> PassItem {
        if instance == nil {
            instance = PassItemStorage().loadPassItem(fromURL: url)
        }
        return instance!
    }
}
