//
//  ImportPGPKeysView.swift
//  Passformac
//
//  Created by Gal on 13/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI


struct ImportPGPKeysView: View {
    
    var onDone: ()->Void
    
    var body : some View {
        VStack {
            Text("Drag here your gpg key file").font(.subheadline)
            ImportKeyIcon(action: { self.onDone() })
            Button(action: { self.onDone() }){
                Text("Skip")
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


