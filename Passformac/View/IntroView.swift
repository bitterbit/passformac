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
        inner
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
                VStack {
                    Text("Drag here your gpg key file").font(.subheadline)
                    ImportKeyIcon()
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


struct ImportKeyIcon: View, DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }

        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            PGPFileReader(keyPath: url.absoluteString)
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
    }
}
