//
//  SetupFromDiskView.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

/**
 Stages:
    
    1. ask user
        - where the local pass folder should be
        - remote git location
    2. try to clone, ask for creds if needed
    3. ask for rsa keys
    4. done
 */

import SwiftUI

struct SetupFromRemoteView: View {
    
    enum Stages: Int {
        case askForLocations = 1
        case cloneRepo = 2
        case askForPGPKeys = 3
        case end = 4
    }
    
    var controller: ViewController
    @State var stage: Stages = .askForLocations
    @State var onDone: () -> Void
    @State var localUrl: String = ""
    @State var remoteUrl: String = ""
    @State var showLoginPopup: Bool = false
    @State var login: Login = Login() // Start with empty credentials, if needed will be filled in
    var loginDoneWaitGroup = DispatchGroup()
    
    var body: some View {
        Form {
            if stage == .askForLocations {
                TextField("remote url", text: $remoteUrl)
                HStack {
                    TextField("local folder", text: $localUrl)
                        .disabled(true)
                        .foregroundColor(Color.gray)
                    Button(action: { self.selectFolder() }) { Text("Select Folder") }
                }
                Button(action: self.initFromRemote) { Text("Clone") }
            }
            else if stage == .cloneRepo && showLoginPopup {
                LoginFormView(login: $login, title: "Authentication") {
                    self.showLoginPopup = false
                    self.loginDoneWaitGroup.leave()
                }
            }
            else if stage == .cloneRepo {
                Text("Cloning...")
            }
            else if stage == .askForPGPKeys {
                ImportPGPKeysView(onDone: { self.nextStage() })
            }
        }
        .onAppear {
            self.onStart()
        }
        
    }
    
    private func onStart() {
        self.localUrl = Config.shared.getLocalDirectory()?.absoluteString ?? ""
    }
    
    private func nextStage() {
        if stage == .end { return } // no need to go to next, we are there now
        
        stage = Stages(rawValue: stage.rawValue + 1)!
        if stage == .end {
            onDone()
        }
    }
    
    private func selectFolder() {
        Directory.selectDirectory() { dir in
            if dir == nil {
                return
            }
            self.localUrl = dir!.absoluteString
        }
    }
    
    private func initFromRemote() {
        guard let remote = URL(string: remoteUrl) else {
            controller.showAlert("Url is not valid")
            return
        }
        
        // validate func class showAlert so no need to show alert twice
        if !validateRemoteUrl(remote) {
            return
        }
        
        guard let local = URL(string: localUrl) else {
            controller.showAlert("No local directory selected")
            return
        }
    
        nextStage()
        
        let handleNeedLogin: () -> (String?, String?) = {
            print("on need creds!")
            self.loginDoneWaitGroup.enter()
            self.showLoginPopup = true
            self.loginDoneWaitGroup.wait() // wait for password to be submitted or cancel called by user
            print("on form submitted!!")
            
            if !self.login.isEmpty() {
                return (self.login.username, self.login.password)
            }
            let n: String? = nil
            return (n, n)
        }
        
        let handleDone: (Bool, Error?) -> Void = {isOk, err in
            if isOk {
                self.controller.setRootDir(rootDir: local)
                self.nextStage()
                return
            }
            
            self.stage = .askForLocations

            guard let err = err as? NSError else {
                self.controller.showAlert("Unknown git error")
                return
            }
            
            let innerError = err.userInfo[NSUnderlyingErrorKey] as! NSError
            self.controller.showAlert(innerError.localizedDescription)
        }
        
        GitRepoCreator.initFromAsync(remote: remote, toLocal: local, onNeedCreds: handleNeedLogin, onDone: handleDone)
    }
    
    private func validateRemoteUrl(_ url: URL) -> Bool {
        if url.scheme != "http" && url.scheme != "https" {
            controller.showAlert("schema is not valid, only http,https currently supported. \(url)")
            return false
        }
        
        if url.host == nil || url.host!.isEmpty {
            controller.showAlert("host is not valid. \(url)")
            return false
        }
        
        if url.path.isEmpty {
            controller.showAlert("path is not valid. \(url)")
            return false
        }
        
        return true
    }
    
}
