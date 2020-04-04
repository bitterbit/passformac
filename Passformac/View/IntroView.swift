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
    
    var body : some View {
        inner.onAppear() {
            let url = self.restoreFolderAccess()
            if url != nil {
                self.controller.setRootDir(rootDir: url!)
                self.currentStage = Stage.givenRootDir
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
                VStack {
                    Text("Drag here your gpg key file").font(.subheadline)
                    ImportKeyIcon(action: {
                        print("on imported!")
                        self.controller.showPage(page: Pages.passphrase)
                    })
                    Button(action: {
                        self.controller.showPage(page: Pages.passphrase)
                    }){ Text("Skip") }
                }
            }
        }
    }
    
    func restoreFolderAccess() -> URL? {
        do {
            var isStale = false

            let bookmarkData = UserDefaults.standard.data(forKey: "workingDirectoryBookmark")
            if bookmarkData == nil {
                return nil
            }
            
            let url = try URL(resolvingBookmarkData: bookmarkData!, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                return nil
            }
            
            // check if we are granted permission
            if !url.startAccessingSecurityScopedResource() {
                return nil
            }
            
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    func openPane() {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                self.controller.setRootDir(rootDir: panel.url!)
                self.currentStage = Stage.givenRootDir
                DirectoryUtils.persistPermissionToFolder(for: panel.url!)
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
