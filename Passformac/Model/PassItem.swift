//
//  PassItem.swift
//  Passformac
//
//  Created by Gal on 29/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

struct PassItem : Identifiable {
    var id = UUID()
    var title: String
    var path: URL
    var username: String?
    var password: String
    var extra: [String: String] = [String: String]()
    
    init(title: String, path: URL) {
        self.path = path
        self.title = title.replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespaces)
        
        self.password = "" // TODO: implement or split to two objects
    }
    
    func load() {
        let content = PGPFileReader.shared.openPassItem(item: self)
        print("content \(content)")
    }
    
    func isLoaded() -> Bool {
        return false
    }
}
