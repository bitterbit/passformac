//
//  ContentView.swift
//  Passformac
//
//  Created by Gal on 28/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var search: String = ""
    @State private var content: [PassItem] = [PassItem]()
    
    @State private var directory: URL?
    
    var body: some View {
        
        VStack {
            Button("reload") {
                self.openPane()
            }
            TextField("search here", text: $search)
            PassList(passItems: self.$content, searchTerm: self.$search)
        }
    }
    
    func listFiles(at: URL?) -> Void{
        if at == nil {
            return
        }
        
        let dir : URL = at!
        do {
            let filemanager = FileManager.default
            let files = try filemanager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for f in files {
                let filename = String(f.lastPathComponent.split(separator: ".")[0])
                let passItem = PassItem(title: filename)
                self.content.append(passItem)
            }
        } catch {
            // do nothing
        }
    }
    
    func openPane() {
        let that : ContentView = self

        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                that.listFiles(at: panel.url!)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
