//
//  PassGitFolder.swift
//  Passformac
//
//  Created by Gal on 01/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import ObjectiveGit


class PassGitFolder {
    // push updates
    // pull updates
    // init from scratch
    
    static func initFromAsync(remote: URL, toLocal: URL, onNeedCreds: @escaping () -> (String?, String?), onDone: @escaping (_ isOk: Bool, Error?) -> ()) {
        let queue = DispatchQueue.init(label: "GIT_THREAD")
        queue.async {
            let (repo, err) = initFrom(remote: remote, toLocal: toLocal, onNeedCreds: onNeedCreds)
            onDone(repo != nil, err)
        }
    }

    static func initFrom(remote: URL, toLocal: URL, onNeedCreds: @escaping () -> (String?, String?)) -> (GTRepository?, Error?) {
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
            let repo = try GTRepository.clone(from: remote, toWorkingDirectory: toLocal, options: options)
            return (repo, nil)
        }
        catch {
            print("error while cloning remote repo: \(error)")
            return (nil, error)
        }
    }
    
    static func initFromScratch(at: URL) {
//        GTReference.git_reference(nil)
    }
}
