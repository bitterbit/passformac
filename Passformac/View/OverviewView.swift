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
            TextField("search here", text: $search)
            PassList(
                controller: controller,
                passItems: passItems,
                searchTerm: self.$search)
        }
    }
}
