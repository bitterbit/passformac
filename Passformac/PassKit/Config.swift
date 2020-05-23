//
//  Config.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectivePGP

class Config {
    
    static var shared : Config = Config()
    private var DEBUG = false
    
    public func needSetup() -> Bool {
        if DEBUG {
            return true // Allows debugging the setup views
        }
        
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
    
    public func getGitRemote() -> String? {
        if !isLocalFolderSet() {
            return nil
        }
        do {
            let repo = try GitPassRepo.init(getLocalDirectory()!)
            return repo.getRemote()
        } catch {
            print("error while getting Pass directory git info. \(error)")
        }
        
        return nil
        
    }
    
    public func getPGPKey(withId id: String) -> Key? {
        let keyring = PersistentKeyring(loadFromKeychain: true, saveToKeychain: false)
        return keyring.getKeyWithId(id)
        
    }
    
    public func getPGPKeys() -> [Key] {
        let keyring = PersistentKeyring(loadFromKeychain: true, saveToKeychain: false)
        return keyring.keys()
    }
}
