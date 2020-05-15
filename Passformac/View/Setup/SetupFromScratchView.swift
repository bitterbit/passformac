//
//  SetupFromScratch.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct SetupFromScratchView : View {
    
    enum Stages: Int {
        case askForLocations = 1
        case initRepo = 2
        case createPGPKeys = 3
        case creatingPGPKeys = 4
        case savePassDirectory = 5
        case end = 6
    }
    
    var controller: ViewController
    @State var onDone: () -> Void
    @State var stage : Stages = .askForLocations
    @State var localURLString : String = ""
    @State var localURL : URL?
    
//    @State var errmsg: String?
//    @State var showError: Bool = false
    
    @State var pgpUsername: String = ""
    @State var pgpPassphrase: String = ""
    
    
    var body : some View {
        Form {
            if stage == .askForLocations {
                Text("Select local folder where the pass repo will be created")
                HStack {
                    TextField("local folder", text: $localURLString)
                        .disabled(true)
                        .foregroundColor(Color.gray)
                    Button(action: self.selectFolder) { Text("Select Folder") }
                }
                Button(action: self.createRepo) { Text("Next") }
            }
            else if stage == .initRepo {
                Text("Creating Repo...")
            }
            else if stage == .createPGPKeys {
                Text("Create PGP Keys")
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                Text("Enter user and password. This password will be used each time you enter the app")
                TextField("user@example.com", text: $pgpUsername)
                SecureField("passphrase", text:$pgpPassphrase)
                Button(action: self.createPGPKeys) { Text("Next") }
            }
            else if stage == .creatingPGPKeys {
                 Text("Creating PGP Keys...")
            }
            else if stage == .savePassDirectory {
                Text("Finishing up...").onAppear() {
                    self.save()
                }
            }
            else {
                Text("Done!").onAppear() {
                    let queue = DispatchQueue(label: "wait_till_done")
                    // delay done by one second
                    queue.asyncAfter(deadline: .now() + 1, execute: {
                        withAnimation { self.onDone() }
                    })
                }
            }
        }.onAppear() {
            self.onStart()
        }
    }
    
    private func onStart() {
        guard let url = Config.shared.getLocalDirectory() else {
            return
        }
        if isSelectedDirectoryEmpty(url){
            self.setLocalUrl(url)
        }
    }
    
    private func setLocalUrl(_ url: URL) {
        localURL = url
        localURLString = url.absoluteString
    }
    
    private func save() {
        guard let url = localURL else {
            self.controller.showAlert("Didn't select directory")
            return
        }
        
        if !PassDirectory.shared.selectPassDirectory(url) {
            self.controller.showAlert("Error while saving directory \(url) as pass directory")
            return
        }
        
        nextStage()
    }
    
    private func nextStage() {
        // no need to go to next, we are at last stage now
        if stage == .end {
            onDone()
            return
        }
        
        stage = Stages(rawValue: stage.rawValue + 1)!
    }
    
    private func selectFolder() {
        Directory.selectDirectory({ dir in
            if dir == nil {
                return
            }
            self.checkDirectoryEmpty(dir!)
            self.setLocalUrl(dir!)
        })
    }
    
    private func createRepo() {
        guard let directory = localURL else {
            self.controller.showAlert("Didn't select directory")
            return
        }

        nextStage()
        do {
            try GitRepoCreator.initFromScratch(directory)
            nextStage()
        } catch {
            self.controller.showError(error)
        }
    }
    
    private func checkDirectoryEmpty(_ url: URL) {
        if isSelectedDirectoryEmpty(url) {
            return
        }
        
        self.controller.showAlert("Directory is not empty")
    }
    
    private func isSelectedDirectoryEmpty(_ url: URL) -> Bool {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            return contents.count == 0;
        } catch let error as NSError {
            // Directory not exist, no permission, etc.
            print(error.localizedDescription)
            print("path: \(self.localURLString)")
        }
        return false
    }
    
    private func createPGPKeys() {
        if self.pgpPassphrase.isEmpty {
            self.controller.showAlert("PGP Passphrase must not be empty")
            return
        }
        
        let queue = DispatchQueue(label: "create_keys_async")
        queue.async {
            PGPFileReader.shared.newKeyPair(user: self.pgpUsername, passphrase: self.pgpPassphrase)
            self.nextStage() // now in done!
        }
        
        self.nextStage() // now in createingPgpKeys
    }
}
