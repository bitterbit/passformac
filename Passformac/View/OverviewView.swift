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
    
    @Binding var passItems: [LazyPassItem]                      // password items
    @State private var search: String = ""                      // filter search term
    @State private var directory: URL?                          // directory that holds the passwords
    @State private var showSpinner: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("search here", text: $search) {
                    let candidates = self.passItems.filter{ passItem in
                        self.search.isEmpty ? true : passItem.title.localizedStandardContains(self.search)
                    }.sorted(by: {$0.title < $1.title })
                    
                    if candidates.count > 0 {
                        let lazyPassItem = candidates[0]
                        self.controller.selectPassItem(item: lazyPassItem.get())
                        self.controller.showPage(page: Pages.detail)
                    }
                }
                Button(action: {
                    self.controller.showPage(page: Pages.new_pass)
                }) {
                    Text("+").bold()
                }
                LoadingButton(loading: $showSpinner, text: "Sync") {
                    self.sync()
                }
            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            PassList(
                controller: controller,
                passItems: passItems,
                searchTerm: self.$search)
            .onAppear() {
                self.controller.refreshPassItems()
            }
        }
    }
    
    private func sync() {
        print("sync...")
        showSpinner = true
        controller.asyncSyncPassItemsWithRemote() {
            print("done!")
            self.showSpinner = false
        }
    }
}
