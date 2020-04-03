//
//  IntroView.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct IntroView : View {
    var controller: ViewController
    
    enum Stage: Int {
        case start = 1
        case givenRootDir = 2
        case givenRootDirAndGPGKeys = 3 // done (do we need it?)
    }
    
    @State private var currentStage: Stage = Stage.start
    @State private var rootDir: URL?
    
    var body : some View {
        VStack{
            Text("Pass for Mac").font(.title)
            if currentStage == Stage.start {
                HStack {
                    Button(action: { self.openPane() }){ Text("Select from disk") }
                    Button(action: { /* TODO: implement */ }) { Text("Initialize new") }
                    Button(action: { /* TODO: implement */ }) { Text("Fetch from github") }
                }
            }
            else if currentStage == Stage.givenRootDir {
                VStack {
                    Text("Drag here your gpg key file").font(.subheadline)
                    Button(action: {
                        self.controller.showOverviewView(rootDir: self.rootDir!)
                    }){ Text("Skip") }
                }
            }
        }
    }
    
    
    func openPane() {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                self.rootDir = panel.url
                self.currentStage = Stage.givenRootDir
            }
        }
    }
}
