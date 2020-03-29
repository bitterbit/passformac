//
//  ContentView.swift
//  Passformac
//
//  Created by Gal on 28/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var content: String = ""
    @State private var search: String = ""
    
    @State private var directory: URL?
    
    var body: some View {
        
        VStack {
            TextField("search here", text: $search)
            
            Text(content)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button("reload") {
                self.openPane()
            }
        }
    }
    
    func listFiles(at: URL?) -> Void{
        if at == nil {
            self.content = "loading..."
            return
        }
        
        let dir : URL = at!
        do {
            let filemanager = FileManager.default
            let files = try filemanager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for f in files {
                self.content += f.lastPathComponent + "\n"
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
