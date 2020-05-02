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
    3. done
 */

import SwiftUI



struct SetupFromRemoteView: View {
    
    enum Stages: Int {
        case askForLocations = 1
        case tryToClone = 2
        case end = 3 // givenRootDirAndGPGKeys done (do we need it?)
    }
    
    var controller: ViewController
    @State var stage: Stages = .askForLocations
    @State var onDone: () -> Void
    
    @State var displayAskForGitCreds: Bool = false
    @State var gitCreds: Login = Login()
    var gitCredsWaitGroup = DispatchGroup()
    
    var body: some View {
        VStack {
            
            if stage == .askForLocations {
                TextField("remote url", text: .constant("GITGIT"))
                HStack {
                    TextField("local folder", text: .constant("GITGIT")).disabled(true)
                    Button(action: { self.openPane() }) { Text("Choose Location") }
                }
            }
            else if stage == .tryToClone {
                Text("Stage try to clone")
            }
            
        }
        .loginAlert(isShowing: $displayAskForGitCreds, login: $gitCreds, title: "TITLE") {
            self.gitCredsWaitGroup.leave()
        }
        .onAppear {
            self.openPane()
        }
    }
    
    private func nextStage() {
        if stage == .end { return } // no need to go to next, we are there now
        
        stage = Stages(rawValue: stage.rawValue + 1)!
        if stage == .end {
            onDone()
        }
    }
    
    private func openPane() {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                self.controller.setRootDir(rootDir: panel.url!)
                self.nextStage()
                PassDirectory.persistPermissionToPassFolder(for: panel.url!)
            }
        }
    }
    
    private func initFromRemote() {
       let remote = URL(string: "https://github.com/bitterbit/pass.git")!
       let local = URL(string: "/tmp/tmptmp")!
       
       PassGitFolder.initFromAsync(remote: remote, toLocal: local, onNeedCreds: {
           print("on need creds!")
           self.gitCredsWaitGroup.enter()
           self.displayAskForGitCreds = true
           self.gitCredsWaitGroup.wait() // wait for password to be submitted or cancel called by user
           print("on form submitted!!")
           
           if !self.gitCreds.isEmpty() {
               return (self.gitCreds.username, self.gitCreds.password)
           }
           let n: String? = nil
           return (n, n)
       })
   }
}
