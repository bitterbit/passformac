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
    var passItemStorage: PassItemStorage?
    var currentPage: Binding<Pages>
    var passItems: Binding<[LazyPassItem]>
    var selectedPassItem: Binding<PassItem?>
    var isShowingLoginAlert: Binding<Bool>
    var loginWaitGroup = DispatchGroup()
    var login: Login?
    
    
    private static var instance: ViewController?
    
    static func get(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>, selectedPassItem: Binding<PassItem?>, isShowingLoginAlert: Binding<Bool>) -> ViewController {
        if instance == nil {
            instance = ViewController(currentPage: currentPage,
                                      passItems: passItems,
                                      selectedPassItem: selectedPassItem,
                                      isShowingLoginAlert: isShowingLoginAlert)
        }
        return instance!
    }
    
    private init(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>, selectedPassItem: Binding<PassItem?>, isShowingLoginAlert: Binding<Bool>) {
        self.currentPage = currentPage
        self.passItems = passItems
        self.selectedPassItem = selectedPassItem
        self.isShowingLoginAlert = isShowingLoginAlert
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
            passItemStorage = PassItemStorage(rootDir!)
            passItems.wrappedValue = passItemStorage!.getPassItems(fromURL: rootDir)
        }
    }
    
    func asyncSyncPassItemsWithRemote() {
        guard let storage = self.passItemStorage else {
            return
        }
        
        let queue = DispatchQueue.init(label: "GIT_THREAD")
        queue.async {
            
            storage.syncRemote(passwordCallback: {
                self.isShowingLoginAlert.wrappedValue = true
                self.loginWaitGroup.enter()
                self.loginWaitGroup.wait()
                return (self.login!.username, self.login!.password)
            })
        }
    }
    
    func onLoginSubmit(login: Login) {
        self.login = login
        self.loginWaitGroup.leave()
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
    @State var showLoginAlert = false
//    var loginWaitGroup = DispatchGroup()
   
    var body: some View {
        routerView.frame(width: 500, height: 500)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            self.getViewController().clearPassphrase()
        }
        .onAppear() {
            if !Config.shared.needSetup() && self.page == .intro {
                self.page = .passphrase
            }
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
        }.loginAlert(isShowing: $showLoginAlert, title: "Authenticate") { login in
            print("on submit \(login)")
            guard let log = login else {
                return
            }
            self.getViewController().onLoginSubmit(login: log)
        }
    }
    
    func getViewController() -> ViewController {
        return ViewController.get(
            currentPage: $page,
            passItems: $passItems,
            selectedPassItem: $selectedPassItem,
            isShowingLoginAlert: $showLoginAlert)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
