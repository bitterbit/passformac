//
//  PersistentKeyring.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectivePGP
import KeychainSwift

class PersistentKeyring {
    private let keyring = Keyring()
    private let keychain = KeychainSwift()

    let ACCESS_GROUP = "Passformac"
    let KEYCHAIN_GPG_KEY = "pgp_key"
    
    init() {
        keychain.accessGroup = ACCESS_GROUP
        self.loadFromDisk()
    }
    
    func firstKey() -> Key? {
        if self.count() > 0 {
            return self.keys()[0]
        }
        return nil
    }
    
    func keys() -> [Key] {
        return self.keyring.keys
    }
    
    func isEmpty() -> Bool {
        return self.count() == 0
    }
    
    func count() -> Int {
        return self.keyring.keys.count
    }
    
    func addKey(fromUrl: URL) throws {
        let contents = try Data(contentsOf: fromUrl)
        let keys = try ObjectivePGP.readKeys(from: contents)
        self.addKeys(keys: keys)
    }
    
    func addKey(key: Key) {
        self.addKeys(keys: [key])
    }
    
    func addKeys(keys: [Key]) {
        keyring.import(keys: keys)
        self.persist()
    }
    
    func persist() {
        do {
            let data = try keyring.export()
            keychain.set(data, forKey: KEYCHAIN_GPG_KEY)
        } catch {
            print("Error while saving key to keychain from keyring \(error)")
        }
    }
    
    private func loadFromDisk() {
        do {
            let keyBlob = keychain.getData(KEYCHAIN_GPG_KEY)
            if keyBlob == nil { return }
            
            let keys = try ObjectivePGP.readKeys(from: keyBlob!)
            keyring.import(keys: keys)
        } catch {
            print("Error while loading key from keychain to keyring \(error)")
        }
    }
}
