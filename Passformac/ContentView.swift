//
//  ContentView.swift
//  Passformac
//
//  Created by Gal on 28/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

enum Pages: String {
    case intro = "page_intro"
    case overview = "page_overview"
    case detail = "page_details"
}

struct ViewController {
    @Binding var currentPage: Pages
    @Binding var passItems: [PassItem]
    @Binding var selectedPassItem: PassItem?
    
    func showDetailView(item: PassItem){
        currentPage = Pages.detail
        selectedPassItem = item
    }
    
    func showOverviewView(rootDir: URL!) {
        currentPage = Pages.overview
        passItems = DirectoryUtils().getPassItems(at: rootDir)
    }
}


struct ContentView: View {
    @State var page = Pages.intro
    @State var selectedPassItem: PassItem?
    
    @State var passItems: [PassItem] = [PassItem]()
   
    var body: some View {
        routerView.frame(width: 500, height: 500)
    }
    
    var routerView: some View {
        VStack {
            if page != Pages.overview && page != Pages.intro {
                Button(action: { self.page = Pages.overview }) { Text("Back") }
            }
            
            if page == Pages.overview {
                OverviewView(
                    controller: getViewController(),
                    passItems: $passItems
                )
            } else if page == Pages.detail {
                if self.selectedPassItem != nil {
                    DetailsView(details: self.selectedPassItem!)
                }
            } else if page == Pages.intro {
                IntroView(controller: getViewController())
            }
        }
    }
    
    func getViewController() -> ViewController {
        return  ViewController(
            currentPage: $page,
            passItems: $passItems,
            selectedPassItem: $selectedPassItem)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
