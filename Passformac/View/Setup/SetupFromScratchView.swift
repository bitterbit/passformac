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
        case end = 5
    }
    
    var controller: ViewController
    @State var onDone: () -> Void
    @State var stage : Stages = .askForLocations
    @State var localUrl : String = ""
    
    @State var errmsg: String?
    @State var showError: Bool = false
    
    @State var pgpUsername: String = ""
    @State var pgpPassphrase: String = ""
    
    
    var body : some View {
        Form {
            if stage == .askForLocations {
                Text("Select local folder where the pass repo will be created")
                HStack {
                    TextField("local folder", text: $localUrl)
                        .disabled(true)
                        .foregroundColor(Color.gray)
                    Button(action: self.selectFolder) { Text("Select Folder") }
                }
                Button(action: self.createRepo) { Text("OK") }
            }
            else if stage == .initRepo {
                Text("Creating Repo...")
            }
            else if stage == .createPGPKeys {
                TextField("user@example.com", text: $pgpUsername)
                SecureField("passphrase", text:$pgpPassphrase)
                Button(action: self.createPGPKeys) { Text("OK") }
            }
            else if stage == .creatingPGPKeys {
                 Text("Creating PGP Keys...")
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
            self.localUrl = Config.shared.getLocalFolder()?.absoluteString ?? ""
        }.alert(isPresented: $showError, content: {
            Alert(title: Text("Error"), message: Text(errmsg ?? "Unknown error"))
        })
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
        PassDirectory.shared.chooseFolder({ dir in
            if dir == nil {
                return
            }
            self.localUrl = dir!.absoluteString
            self.controller.setRootDir(rootDir: dir!)
        })
    }
    
    private func createRepo() {
        if !isSelectedFolderEmpty() {
            errmsg = "Folder is not empty"
            showError = true
            return
        }
        let folder = Config.shared.getLocalFolder()!
        nextStage()
        
        do {
            try GitRepoCreator.initFromScratch(folder)
            try PassDirectory.shared.loadExistingPassFolder(folder)
            nextStage()
        } catch {
            errmsg = error.localizedDescription
            showError = true
        }
    }
    
    private func isSelectedFolderEmpty() -> Bool {
        guard let folder = Config.shared.getLocalFolder() else {
            return false
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [])
            return contents.count == 0;
        } catch let error as NSError {
            // Directory not exist, no permission, etc.
            print(error.localizedDescription)
            print("path: \(self.localUrl)")
        }
        return false
    }
    
    private func createPGPKeys() {
        if self.pgpPassphrase.isEmpty {
            errmsg = "PGP Passphrase must not be empty"
            showError = true
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
