//
//  Config.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation

class Config {
    
    static var shared : Config = Config()
    
    public func needSetup() -> Bool {
        if !isLocalFolderSet() {
            return true
        }
        
        if !PGPFileReader.shared.hasPrivateKey() {
            return true
        }
        
        if !PGPFileReader.shared.hasPublicKey() {
            return true
        }
        
        return false
    }
    
    public func isLocalFolderSet() -> Bool {
        return getLocalFolder() != nil
    }
    
    public func getLocalFolder() -> URL? {
        return PassDirectory.shared.getSavedPassFolder()
    }
}
