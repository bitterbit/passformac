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
    
    func set(passphrase: String) {
        self.passphrase = passphrase
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
    
    func loadRawPassItem(at: URL) -> String {
        let key = presistentKeyring.firstKey() // TODO support multiple keys (.gpg-id)
        if key == nil {
            return ""
        }
        
        let rawPassItem = self.readFile(at: at, key: key!)
        return rawPassItem
    }
    
    func savePassItem(item: PassItem, at: URL) -> Bool {
        let key = presistentKeyring.firstKey()
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
            let encrypted = try Data(contentsOf: at)
            let encryptedAscii = Armor.armored(encrypted, as: .publicKey)
        
            
            var decryptingKey = key
            if passphrase != nil {
                decryptingKey = (try? (key.decrypted(withPassphrase: self.passphrase!))) ?? key
            }
            
            let decrypted = try ObjectivePGP.decrypt(encryptedAscii.data(using: .utf8)!, andVerifySignature: true, using: [decryptingKey])
            return String(bytes: decrypted, encoding: .utf8)!
        }
        catch {
            print("error while reading encrypted file. error: \(error)")
            return ""
        }
    }
    
    func writeFile(at: URL!, key: Key, data: Data) -> Bool {
        do {
            let encrypted = try ObjectivePGP.encrypt(data, addSignature: true, using: [key])
            try encrypted.write(to: at)
        }
        catch {
            print("error while writing encrypted file. error: \(error)")
            return false
        }
        return true
    }
}
