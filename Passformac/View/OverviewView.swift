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
    
    @Binding var passItems: [PassItem]                          // password items
    @State private var search: String = ""                      // filter search term
    @State private var directory: URL?                          // directory that holds the passwords
    
    var body: some View {
        VStack {
            TextField("search here", text: $search) {
                let candidates = self.passItems.filter{ passItem in
                    self.search.isEmpty ? true : passItem.title.localizedStandardContains(self.search)
                }.sorted(by: {$0.title < $1.title })
                
                if candidates.count > 0 {
                    self.controller.selectPassItem(item: candidates[0])
                    self.controller.showPage(page: Pages.detail)
                }
            }
            PassList(
                controller: controller,
                passItems: passItems,
                searchTerm: self.$search)
        }
    }
}
