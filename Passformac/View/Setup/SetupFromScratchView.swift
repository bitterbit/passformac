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
        case end = 4
    }
    
    var controller: ViewController
    @State var onDone: () -> Void
    @State var stage : Stages = .askForLocations
    @State var localUrl : String = ""
    
    
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
                Button(action: self.nextStage) { Text("OK") }
            }
            else if stage == .initRepo {
                Text("init Repo")
            }
            else if stage == .createPGPKeys {
                Text("init PGP Keys")
            }
            else {
                Text("Done")
            }
        }.onAppear() {
            self.localUrl = Config.shared.getLocalFolder()?.absoluteString ?? ""
        }
    }
    
    private func nextStage() {
        if stage == .end { return } // no need to go to next, we are there now
        
        stage = Stages(rawValue: stage.rawValue + 1)!
        if stage == .end {
            onDone()
        }
    }
    
    private func selectFolder() {
        PassDirectory.choosePassFolder({ dir in
            if dir == nil {
                return
            }
            self.localUrl = dir!.absoluteString
            self.controller.setRootDir(rootDir: dir!)
        })
    }
}
