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
    var isShowingErrorAlert: Binding<Bool>
    var errorMessage: Binding<String?>
    var loginWaitGroup = DispatchGroup()
    var login: Login?
    
    
    private static var instance: ViewController?
    
    static func get(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>,
                    selectedPassItem: Binding<PassItem?>, isShowingLoginAlert: Binding<Bool>,
                    isShowingErrorAlert: Binding<Bool>, errorMessage: Binding<String?>) -> ViewController {
        if instance == nil {
            instance = ViewController(currentPage: currentPage,
                                      passItems: passItems,
                                      selectedPassItem: selectedPassItem,
                                      isShowingLoginAlert: isShowingLoginAlert,
                                      isShowingErrorAlert: isShowingErrorAlert,
                                      errorMessage: errorMessage)
        }
        return instance!
    }
    
    private init(currentPage: Binding<Pages>, passItems: Binding<[LazyPassItem]>,
                 selectedPassItem: Binding<PassItem?>, isShowingLoginAlert: Binding<Bool>,
                 isShowingErrorAlert: Binding<Bool>, errorMessage: Binding<String?>) {
        self.currentPage = currentPage
        self.passItems = passItems
        self.selectedPassItem = selectedPassItem
        self.isShowingLoginAlert = isShowingLoginAlert
        self.isShowingErrorAlert = isShowingErrorAlert
        self.errorMessage = errorMessage
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
        rootDir = Config.shared.getLocalDirectory()
        if rootDir != nil {
            passItemStorage = PassItemStorage(rootDir!)
            passItems.wrappedValue = passItemStorage!.getPassItems(fromURL: rootDir)
        }
    }
    
    func asyncSyncPassItemsWithRemote(onDone: @escaping () -> Void) {
        guard let storage = self.passItemStorage else {
            return
        }
        
        let queue = DispatchQueue.init(label: "GIT_THREAD")
        queue.async {
            var canceled = false
            let err = storage.syncRemote(passwordCallback: {
                print("on git authentication callback")
                self.isShowingLoginAlert.wrappedValue = true
                self.loginWaitGroup.enter()
                self.loginWaitGroup.wait()
                if (self.login!.isEmpty()) {
                    canceled = true
                    return (nil, nil)
                }
                return (self.login!.username, self.login!.password)
            })
            
            onDone()
            if err != nil && !canceled {
                self.showError(err!)
            }
        }
    }
    
    func onLoginSubmit(_ login: Login) {
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
    
    
    func showError(_ err: Error) {
        showAlert(err.localizedDescription)
    }
    
    func showAlert(_ msg: String) {
        self.errorMessage.wrappedValue = msg
        self.isShowingErrorAlert.wrappedValue = true
    }
    
    
}


struct ContentView: View {
    @State var page = Pages.intro
    @State var selectedPassItem: PassItem?
    @State var passItems: [LazyPassItem] = [LazyPassItem]()
    @State var showLoginAlert = false
    @State var showErrorAlert = false
    @State var errorMessage : String?
   
    var body: some View {
        routerView.frame(width: 500, height: 500)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            self.getViewController().clearPassphrase()
        }
        .onAppear() {
            if Config.shared.needSetup() {
                Config.shared.reset() // in case we have leftovers from some previous app instance
                self.page = .intro
            }
            else if self.page == .intro {
                self.page = .passphrase
            }
        }.alert(isPresented: $showErrorAlert, content: {
            Alert(title: Text("Error"), message: Text(self.errorMessage ?? "Unknown error"))
        })
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
            // submit even if cancel, it's important so the waitgroup will be freed.
            // controller.login will get an empty login which is treated as if there is no valid login
            self.getViewController().onLoginSubmit(login)
        }
    }
    
    func getViewController() -> ViewController {
        return ViewController.get(
            currentPage: $page,
            passItems: $passItems,
            selectedPassItem: $selectedPassItem,
            isShowingLoginAlert: $showLoginAlert,
            isShowingErrorAlert: $showErrorAlert,
            errorMessage: $errorMessage
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
