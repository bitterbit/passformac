//
//  IntroView.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

enum Stage: Int {
    case start = 1
    case givenRootDir = 2
    case end = 3 // givenRootDirAndGPGKeys done (do we need it?)
}



struct IntroView : View {
    var controller: ViewController
    @State private var currentStage: Stage = Stage.start
    @State private var displayAskForGitCreds: Bool = false
    @State private var gitCreds = Login()
    var gitCredsWaitGroup = DispatchGroup()
    
    var body : some View {
        inner.onAppear() {
            let url = PassDirectory.getSavedPassFolder()
            if url != nil {
//                self.controller.setRootDir(rootDir: url!)
                // We have permission to pass folder, skip to next step
//                self.nextStage()
            }
        }
    }
    
    var inner : some View {
        VStack{
            Text("Pass for Mac").font(.title)
            if currentStage == Stage.start {
                HStack {
                    Button(action: { self.openPane() }){ Text("Select from disk") }
                    Button(action: { /* TODO: implement */ }) { Text("Initialize new") }.disabled(true)
                    Button(action: { self.initFromRemote() }) { Text("Fetch from github") } // .disabled(true)
                }
            }
            else if currentStage == Stage.givenRootDir {
                ImportPGPKeysView(onDone: {
                    self.nextStage()
                })
            }
        }.loginAlert(isShowing: $displayAskForGitCreds, login: $gitCreds, title: "TITLE") {
            self.gitCredsWaitGroup.leave()
        }
    }
    
    private func nextStage() {
        print("nextStage() current:\(currentStage)")
        if (currentStage == Stage.end) { return } // no need to go to next, we are there now
        currentStage = Stage(rawValue: currentStage.rawValue + 1)!
        
        // We arrived at the last stage, lets move on to passphrase
        if (currentStage == Stage.end) {
            self.controller.showPage(page: Pages.passphrase)
            return
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
}
