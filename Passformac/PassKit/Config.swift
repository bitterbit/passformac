//
//  Config.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

class Config {
    // local folder
    // remote url
    // private and public key
    
    static var shared : Config = Config()
    
    public func isLocalFolderSet() -> Bool {
        return getLocalFolder() != nil
    }
    
    public func getLocalFolder() -> URL? {
        return PassDirectory.getSavedPassFolder()
    }
}
