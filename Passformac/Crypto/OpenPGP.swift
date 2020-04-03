//
//  OpenPGP.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectivePGP

struct PGPFileReader {

    let keyring = Keyring()
    
    init(keyPath: String) {
        do {
            try keyring.import(keys: ObjectivePGP.readKeys(fromPath: keyPath))
        } catch { /* no keys for you */ }
    }
    
    init(key: Data) {
        do {
            try keyring.import(keys: ObjectivePGP.readKeys(from: key))
        } catch { /* no keys */ }
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
