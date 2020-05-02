//
//  EditPassView.swift
//  Passformac
//
//  Created by Gal on 12/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct EditPassView : View {
    
    @State var title: String = ""
    @State var login: String = ""
    @State var password: String = ""
    @State var website: String = ""
    
    
    
    @State private var showAlert: Bool = false
    
    @State private var actualExtras : [Binding<PassExtra>] = [Binding<PassExtra>]()
    
    var extra: [PassExtra] = [PassExtra]()
    var controller: ViewController
    // var passItemStorage: PassItemStorage
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.closeView() }) { Text("Cancel") }
                Spacer()
                Button(action: {
                    let ok = self.save()
                    self.showAlert = !ok
                    if ok { self.closeView() }
                }) { Text("Save") }.alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Error"), message: Text("Error while saving"), dismissButton: .default(Text("ok")))
                }
            }
            Form {
                LabelTextView(label: "Name", value: $title)
                LabelTextView(label: "Login", value: $login)
                EditPasswordView(password: $password)
                LabelSeperatorView(label: "Extra")
                LabelTextView(label: "Website", placeHolder: "http://", value: $website)
                EditPassExtrasView(extra: self.extra, onUpdate: { updatedExtra in
                    print("on update")
                    self.actualExtras = updatedExtra
                })
                
            }
            Spacer()
        }.padding(15)
    }
    
    private func closeView() {
        self.controller.showPage(page: Pages.overview)
    }
    
    private func save() -> Bool {
        let dir = PassDirectory.shared.getSavedPassFolder()
        if dir == nil || title == "" {
            return false
        }
        
        let filename = self.title.replacingOccurrences(of:" " , with: "_") + ".pgp"
        let url = dir!.appendingPathComponent(filename)
        var passItem = PassItem(title: title)
        passItem.username = self.login
        passItem.password = self.password
        passItem.extra = self.actualExtras.map { $0.wrappedValue }
        if !self.website.isEmpty {
            passItem.extra.append(PassExtra(key: "website", value: website))
        }
        
        return controller.passItemStorage!.savePassItem(atURL: url, item: passItem)
    }
    
    
    static func getViewForPassItem(_ item: PassItem, controller: ViewController) -> EditPassView {
        var extra = item.extra
        var website = ""
        let websites = extra.filter { $0.key.lowercased() == "website" }
        if websites.count > 0 {
            extra = extra.filter { $0 != websites[0] } // don't show website field twice
            website = websites[0].value
        }
        
        return EditPassView(title: item.title,
                            login: item.username ?? "",
                            password: item.password,
                            website: website,
                            extra: extra,
                            controller: controller
        )
    }
}



#if DEBUG
struct EditPassView_Previews: PreviewProvider {
   
    
    static var previews: some View {
        EditPassView(
            title: "Title",
            login: "username@gmail.com",
            password: "Password1",
            extra: [
                PassExtra(key: "Extra #1", value: "extravalue"),
                PassExtra(key: "Extra #2", value: "otherextravalue")
            ],
            controller: getViewController()
        )
    }
    
    static private func getViewController() -> ViewController {
        return ViewController.get(
            currentPage: .constant(Pages.edit_pass),
            passItems: .constant([LazyPassItem]()),
            selectedPassItem: .constant(nil))
    }
}
#endif
