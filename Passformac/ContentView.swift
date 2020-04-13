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
    case passphrase = "page_passphrase"
    case overview = "page_overview"
    case detail = "page_details"
    case new_pass = "page_new_pass"
    case edit_pass = "page_edit_pass"
}

struct ViewController {
    @Binding var currentPage: Pages
    @Binding var passItems: [LazyPassItem]
    @Binding var selectedPassItem: PassItem?
    
    func setPassphrase(passphrase: String){
        PGPFileReader.shared.set(passphrase: passphrase)
    }
    
    func clearPassphrase() {
        PGPFileReader.shared.set(passphrase: "")
        if currentPage != Pages.intro {
            self.showPage(page: Pages.passphrase)
        }
    }
    
    func setRootDir(rootDir: URL){
        passItems = PassItemStorage().getPassItems(fromURL: rootDir)
    }
    
    func showPage(page: Pages) {
        currentPage = page
    }
    
    func selectPassItem(item: PassItem) {
        selectedPassItem = item
    }
}


struct ContentView: View {
    @State var page = Pages.intro
    @State var selectedPassItem: PassItem?
    @State var passItems: [LazyPassItem] = [LazyPassItem]()
   
    var body: some View {
        routerView.frame(width: 500, height: 500)
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
                self.getViewController().clearPassphrase()
            }
    }
    
    var routerView: some View {
        VStack {
            if page == Pages.detail {
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
            } else if page == Pages.passphrase {
                PassphraseView(controller: getViewController())
            } else if page == Pages.new_pass {
                EditPassView(controller: getViewController())
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
