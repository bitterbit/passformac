//
//  OpenPGP.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectivePGP

class PGPFileReader {
    // singleton instance
    static var shared: PGPFileReader = PGPFileReader()
    var presistentKeyring = PersistentKeyring()
    var passphrase: String? = nil

    private init() {}
    
    func reset() {
        self.presistentKeyring.reset()
        self.passphrase = nil
    }
    
    func set(passphrase: String) {
        self.passphrase = passphrase
    }
    
    func hasPublicKey() -> Bool {
        return presistentKeyring.hasPublicKey()
    }
    
    func hasPrivateKey() -> Bool {
        return presistentKeyring.hasPrivateKey()
    }
    
    func importKey(at url: URL) -> Bool {
        do {
            // Note: for some reason reading from full path string doesnt work but reading from url works
            try presistentKeyring.addKey(fromUrl: url)
            print("keyring now has \(presistentKeyring.count()) keys")
            return true
        } catch {
            /* no keys for you */
            print("Unexpected error: \(error).")
        }
        
        return false // un-successful
    }
    
    func newKeyPair(user: String, passphrase: String) {
        presistentKeyring.createAndStoreKeyPair(user: user, withPassphrase: passphrase)
    }
    
    func loadRawPassItem(at: URL) -> String {
        let key = presistentKeyring.firstPrivateKey() // TODO support multiple keys (.gpg-id)
        if key == nil {
            return ""
        }
        
        let rawPassItem = self.readFile(at: at, key: key!)
        return rawPassItem
    }
    
    func savePassItem(item: PassItem, at: URL) -> Bool {
        let key = presistentKeyring.firstPublicKey()
        if key == nil {
            return false
        }
        
        let data = item.serialize().data(using: .utf8)
        if data == nil {
            return false
        }
        
        return self.writeFile(at: at, key: key!, data: data!)
    }
    
    func readFile(at: URL!, key: Key) -> String {
        do {
            let encrypted = try Data(contentsOf: at) // file
            let encryptedAscii = Armor.armored(encrypted, as: .publicKey) // ObjectivePGP prefers decrypting in ascii (armor) mode for some reason
            let decryptingKey = decryptKeyIfHasPassphrase(key, passphrase: passphrase)
            let decrypted = try ObjectivePGP.decrypt(encryptedAscii.data(using: .utf8)!, andVerifySignature: true, using: [decryptingKey])
            return String(bytes: decrypted, encoding: .utf8)!
        }
        catch {
            print("error while reading encrypted file. error: \(error)")
            return ""
        }
    }
    
    func decryptKeyIfHasPassphrase(_ key: Key, passphrase:String?) -> Key {
        if passphrase != nil {
            do {
                return try key.decrypted(withPassphrase: passphrase!)
            } catch {
                print("clould not decrypt key with passphrase")
            }
        }
        return key
    }
    
    func validatePassphrase(_ passphrase: String) -> Bool {
        guard let key = presistentKeyring.firstPrivateKey() else {
            return false
        }
        
        let decrypted = decryptKeyIfHasPassphrase(key, passphrase: passphrase)
        return decrypted.isEncryptedWithPassword == false
    }
    
    func validatePassphrase() -> Bool {
        guard let pass = self.passphrase else {
            return false
        }
        return self.validatePassphrase(pass)
    }
    
    func writeFile(at: URL!, key: Key, data: Data) -> Bool {
        do {
            let encrypted = try ObjectivePGP.encrypt(data, addSignature: false, using: [key])
            try encrypted.write(to: at)
        }
        catch {
            print("error while writing encrypted file. error: \(error)")
            return false
        }
        return true
    }
}
