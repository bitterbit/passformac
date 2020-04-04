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
    
    let keyring = Keyring()
    var passphrase: String? = nil

    private init() {}
    
    func set(passphrase: String) {
        self.passphrase = passphrase
    }
    
    func importKey(at: URL) -> Bool {
        do {
            // for some reason reading from full path string doesnt work but reading from url works
            let contents = try Data(contentsOf: at)
            try keyring.import(keys: ObjectivePGP.readKeys(from: contents))
            print("keyring now has \(keyring.keys.count) keys")
            return true
        } catch {
            /* no keys for you */
            print("Unexpected error: \(error).")
        }
        
        return false // un-successful
    }
    
    func openPassItem(item: PassItem) -> String {
        let key = keyring.keys[0] // TODO support multiple keys (.gpg-id)
        let rawPassItem = self.readFile(at: item.path, key: key)
        print("raw pass item \(rawPassItem)")
        return rawPassItem
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
}
