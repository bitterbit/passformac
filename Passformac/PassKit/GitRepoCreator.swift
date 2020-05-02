//
//  PassGitFolder.swift
//  Passformac
//
//  Created by Gal on 01/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectiveGit


class GitRepoCreator {
    static func initFromAsync(remote: URL, toLocal: URL, onNeedCreds: @escaping () -> (String?, String?), onDone: @escaping (_ isOk: Bool, Error?) -> ()) {
        let queue = DispatchQueue.init(label: "GIT_THREAD")
        queue.async {
            let (err) = initFrom(remote: remote, toLocal: toLocal, onNeedCreds: onNeedCreds)
            onDone(err == nil, err)
        }
    }

    static func initFrom(remote: URL, toLocal: URL, onNeedCreds: @escaping () -> (String?, String?)) -> (Error?) {
        let onCredsNeededAdapter = { (type: GTCredentialType, url: String, username: String) -> GTCredential? in
            do {
                if type != .userPassPlaintext {
                    return nil // Unsupported credentials type, give up
                }
                
                let (user, password) = onNeedCreds()
                if user == nil || password == nil {
                    return nil
                }
            
                let creds = try GTCredential.init(userName: user!, password: password!)
                return creds
            } catch {
                print("error while asking for creds from user. err: \(error)")
            }
            
            return nil
        }
        
        let options : [AnyHashable: Any] = [
            GTRepositoryCloneOptionsCredentialProvider: GTCredentialProvider.init(block: onCredsNeededAdapter)
        ]
        
        do {
            _ = try GTRepository.clone(from: remote, toWorkingDirectory: toLocal, options: options)
            return (nil)
        }
        catch {
            print("error while cloning remote repo: \(error)")
            return (error)
        }
    }
    
    static func initFromScratch(_ url: URL) throws {
        _ = try GTRepository.initializeEmpty(atFileURL: url)
    }
    
    static func initFromLocalFolder(_ localUrl: URL) throws  {
        _ = try GTRepository.init(url: localUrl)
    }
    
}
