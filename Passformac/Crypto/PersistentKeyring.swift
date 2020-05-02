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
    
    private let saveToKeychain: Bool

    let ACCESS_GROUP = "Passformac"
    let KEYCHAIN_GPG_KEY = "passformac_pgp_keys"
    
    init(loadFromKeychain: Bool = true, saveToKeychain: Bool = true) {
        keychain.accessGroup = ACCESS_GROUP
        self.saveToKeychain = saveToKeychain
        
        if loadFromKeychain {
            self.loadFromKeychain()
        }
    }
    
    func hasPublicKey() -> Bool {
        return self.keys(privateKeys: false, publicKeys: true).count > 0
    }
    
    func hasPrivateKey() -> Bool {
        return self.keys(privateKeys: true, publicKeys: false).count > 0
    }
    
    func firstPrivateKey() -> Key? {
        if !self.hasPrivateKey() {
            return nil
        }
        return keys(privateKeys: true, publicKeys: false)[0]
    }
    
    func firstPublicKey() -> Key? {
        if !self.hasPublicKey() {
            return nil
        }
        return keys(privateKeys: false, publicKeys: true)[0]
    }
    
    func keys(privateKeys: Bool = true, publicKeys: Bool = true) -> [Key] {
        var keys = [Key]()
        for key in keyring.keys {
            if publicKeys && key.isPublic {
                keys.append(key)
            }
            if privateKeys && key.isSecret {
                keys.append(key)
            }
        }
        
        return keys
    }
    
    func createAndStoreKeyPair(user: String, withPassphrase: String?) {
        let key = KeyGenerator().generate(for: user, passphrase: withPassphrase)
        addKey(key: key)
        persist()
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
        if !self.saveToKeychain {
            return
        }
        
        do {
            let data = try keyring.export()
            keychain.set(data, forKey: KEYCHAIN_GPG_KEY)
        } catch {
            print("Error while saving key to keychain from keyring \(error)")
        }
    }
    
    private func loadFromKeychain() {
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
