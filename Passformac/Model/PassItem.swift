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
    var username: String?
    var password: String
    var extra: [PassExtra] = [PassExtra]()
    
    init(title: String) {
        self.title = title.replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespaces)
        self.password = ""
    }
 
    
    func serialize() -> String {
        var content = ""
        content += self.password
        
        if self.username != nil {
            content += "Login: \(self.username!)"
        }
        
        for extraItem in self.extra {
            content += "\(extraItem.key): \(extraItem.value)"
        }
        
        return content
    }
    
    mutating func unserialize(content: String) {
        let lines = content.components(separatedBy: "\n")
        if lines.count <= 0 {
            return
        }
        
        // We may not have a password at all,
        // password isn't of key:value format, and is always the first line
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
}
