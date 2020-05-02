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

class ViewController {
    private var rootDir: URL?
    var currentPage: Binding<Pages>
    var passItems: Binding<[LazyPassItem]>
    var selectedPassItem: Binding<PassItem?>
    
    private static var instance: ViewController?
    
    static func get(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>, selectedPassItem: Binding<PassItem?>) -> ViewController {
        if instance == nil {
            instance = ViewController(currentPage: currentPage,
                                      passItems: passItems,
                                      selectedPassItem: selectedPassItem)
        }
        return instance!
    }
    
    private init(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>, selectedPassItem: Binding<PassItem?>) {
        self.currentPage = currentPage
        self.passItems = passItems
        self.selectedPassItem = selectedPassItem
    }
    
    func setPassphrase(passphrase: String){
        PGPFileReader.shared.set(passphrase: passphrase)
    }
    
    func clearPassphrase() {
        PGPFileReader.shared.set(passphrase: "")
        let page = currentPage.wrappedValue
        if page != .intro && page != .edit_pass && page != .new_pass {
            self.showPage(page: Pages.passphrase)
        }
    }
    
    func setRootDir(rootDir: URL){
        self.rootDir = rootDir
        refreshPassItems()
    }
    
    func refreshPassItems() {
        rootDir = Config.shared.getLocalFolder()
        if rootDir != nil {
            passItems.wrappedValue = PassItemStorage().getPassItems(fromURL: rootDir)
        }
    }
    
    func showPage(page: Pages) {
        currentPage.wrappedValue = page
    }
    
    func selectPassItem(item: PassItem) {
        selectedPassItem.wrappedValue = item
    }
    
    func editPassItem(item: PassItem) {
        self.selectPassItem(item: item)
        self.showPage(page: .edit_pass)
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
            if page == Pages.overview {
                OverviewView(
                    controller: getViewController(),
                    passItems: $passItems
                )
            } else if page == .detail && selectedPassItem != nil  {
                DetailsView(controller: getViewController(), details: selectedPassItem!)
            } else if page == .intro {
                IntroView(controller: getViewController())
            } else if page == .passphrase {
                PassphraseView(controller: getViewController())
            } else if page == .new_pass {
                EditPassView(controller: getViewController())
            } else if page == .edit_pass && selectedPassItem != nil {
                EditPassView.getViewForPassItem(selectedPassItem!, controller: getViewController())
            }
        }
    }
    
    func getViewController() -> ViewController {
        return ViewController.get(
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
