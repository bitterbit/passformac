//
//  SetupFromDiskView.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

/**
 Stages:
    1. ask user to point out where the local pass folder is
    2. ask for private and public keys for the local pass repository
    3. done
 */

import SwiftUI

struct SetupFromDiskView: View {
    
    enum Stages: Int {
        case askForLocalDir = 1
        case askForPGPKeys = 2
        case end = 3
    }
    
    var controller: ViewController
    @State var stage: Stages = .askForLocalDir
    @State var onDone: () -> Void
    
    var body: some View {
        VStack {
            if stage == .askForLocalDir {
                Text("Select the directory for the pass repository")
            }
            else if stage == .askForPGPKeys {
                ImportPGPKeysView(onDone: { self.nextStage() })
            }
            
        }.onAppear {
            if Config.shared.isLocalFolderSet() {
                self.nextStage()
                return
            }
            
            PassDirectory.choosePassFolder({ dir in
                if dir == nil {
                    return
                }
                
                self.controller.setRootDir(rootDir: dir!)
                self.nextStage()
            })
        }
    }
    
    private func nextStage() {
        if stage == .end { return } // no need to go to next, we are there now
        
        stage = Stages(rawValue: stage.rawValue + 1)!
        if stage == .end {
            onDone()
        }
    }
}
