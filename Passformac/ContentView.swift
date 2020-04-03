//
//  ContentView.swift
//  Passformac
//
//  Created by Gal on 28/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

enum Pages: String {
    case overview = "page_overview"
    case detail = "page_details"
}

struct ViewController {
    @Binding var currentPage: Pages
    @Binding var currentDetails: PassItem?
    
    func showDetailView(item: PassItem){
        currentPage = Pages.detail
        currentDetails = item
    }
}


struct ContentView: View {
    @State var page = Pages.overview
    @State var currentDetails: PassItem?
    
    @State var passItems: [PassItem] = [PassItem]()
   
    var body: some View {
        routerView.frame(width: 500, height: 500)
    }
    
    var routerView: some View {
        VStack {
            HStack {
                Button(action: { self.page = Pages.overview }) {
                    Text("Back")
                }
                Button(action: { self.openPane() }) {
                    Text("Reload")
                }
            }
           
            
            if page == Pages.overview {
                OverviewView(
                    controller: ViewController(currentPage: $page, currentDetails: $currentDetails),
                    passItems: $passItems
                )
            } else if page == Pages.detail {
                if self.currentDetails != nil {
                    DetailsView(details: self.currentDetails!)
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
                self.passItems = DirectoryUtils().getPassItems(at: panel.url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
