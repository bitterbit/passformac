//
//  PassItem.swift
//  Passformac
//
//  Created by Gal on 29/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

struct PassExtra : Identifiable {
    var id = UUID()
    var key: String
    var value: String
}

struct PassItem : Identifiable {
    var id = UUID()
    var title: String
    var path: URL
    var username: String?
    var password: String
    var extra: [PassExtra] = [PassExtra]()
    
    init(title: String, path: URL) {
        self.path = path
        self.title = title.replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespaces)
        self.password = ""
    }
    
    mutating func load() {
        let content = PGPFileReader.shared.openPassItem(item: self)
        let lines = content.components(separatedBy: "\n")
        if lines.count <= 0 {
            return
        }
        
        // We may not have a password at all, password doesnt have key:value format
        if !lines[0].contains(":") {
            self.password = lines[0]
        }
        
        for line in lines[1...] {
            let components = line.components(separatedBy: ":")
            if components.count <= 1 {
                continue
            }
            
            let key = components[0]
            let value = components[1]
            if key == "Login" {
                self.username = value
                continue
            }
            
            extra.append(PassExtra(key: key, value: value))
        }
    }
    
    func isLoaded() -> Bool {
        return false
    }
}
