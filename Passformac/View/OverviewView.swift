//
//  ContentView.swift
//  Passformac
//
//  Created by Gal on 28/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct OverviewView: View {
    var controller: ViewController
    
    @State private var passItems: [PassItem] = [PassItem]()       // password items
    @State private var search: String = ""                      // filter search term
    @State private var directory: URL?                          // directory that holds the passwords
    
    var body: some View {
        VStack {
            Button("reload") {
                self.openPane()
            }
            TextField("search here", text: $search)
            PassList(controller: controller, passItems: self.$passItems, searchTerm: self.$search)
        }
    }
    
    func openPane() {
        let panel = NSOpenPanel()
        panel.showsHiddenFiles = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        
        panel.begin { (result) in
            if result == .OK && panel.url != nil {
                self.passItems = DirectoryUtils().getPassItems(at: panel.url)
            }
        }
    }
}
