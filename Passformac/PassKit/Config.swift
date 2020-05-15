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
//        return true // TODO remove after testing
        
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
    
    public func reset() {
        PassDirectory.shared.resetSavedPassDirectory()
        PGPFileReader.shared.reset() // this might be confusing but this actually resets the PGP keys stored in the keychain
                                     // because PGPFileReader is the owner of the PersistentKeyring
    }
    
    public func isLocalFolderSet() -> Bool {
        return getLocalDirectory() != nil
    }
    
    public func getLocalDirectory() -> URL? {
        return PassDirectory.shared.getSavedPassFolder()
    }
}
