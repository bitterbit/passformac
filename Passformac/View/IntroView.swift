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
    
    var body : some View {
        inner.onAppear() {
            let url = PassDirectory.getSavedPassFolder()
            if url != nil {
                self.controller.setRootDir(rootDir: url!)
                // We have permission to pass folder, skip to next step
                self.nextStage()
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
                    Button(action: { /* TODO: implement */ }) { Text("Fetch from github") }.disabled(true)
                }
            }
            else if currentStage == Stage.givenRootDir {
                setupPgpStage.onAppear(){
                    let keyring = PersistentKeyring()
                    if !keyring.isEmpty() {
                        self.nextStage()
                    }
                }
            }
        }
    }
    
    var setupPgpStage : some View {
        VStack {
            Text("Drag here your gpg key file").font(.subheadline)
            ImportKeyIcon(action: {
                print("on imported!")
                self.nextStage()
            })
            Button(action: {
                self.nextStage()
            }){ Text("Skip") }
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


struct ImportKeyIcon: View, DropDelegate {
    var action: () -> Void
    
    @State private var isShowingAlert = false
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }

        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            if !PGPFileReader.shared.importKey(at: url) {
                self.isShowingAlert = true
            }
            
            self.action()
        }
        return true
    }
    
    
    var body : some View {
        Image("drop-here")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100, alignment: .center)
            .padding(20)
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
            .alert(isPresented: $isShowingAlert) {
                // TODO: error details
                Alert(title: Text("Error importing pgp file"), message: Text("Error details..."))
            }
        
    }
}
