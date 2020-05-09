//
//  Folder.swift
//  Passformac
//
//  Created by Gal on 09/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import AppKit

class Directory {
    typealias SelectDirectoryDeleage = (URL?) -> Void
    
    // doesnt validate the git setup
    // desont save the result
    static func selectDirectory(_ onDone: @escaping SelectDirectoryDeleage) {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                onDone(panel.url)
            } else {
                onDone(nil)
            }
        }
    }
    
}
