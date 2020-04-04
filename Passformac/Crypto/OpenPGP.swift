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
    
    private init() {}
    
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
    
    func readFile(at: URL!, withIdentifiers: [String]) -> String {
        var keys = [Key]()
        for identifier in withIdentifiers {
            let key = keyring.findKey(identifier)
            if key != nil {
                keys.append(key!)
            }
        }
        
        do {
            let encrypted = try Data(contentsOf: at)
            let decrypted = try ObjectivePGP.decrypt(encrypted, andVerifySignature: true, using: keys)
            let decryptedString = String(bytes: decrypted, encoding: .utf8)
            return decryptedString!
        }
        catch { return "" }
    }
}
