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
    @State var extra: [PassExtra] = [PassExtra]()
    
    @State var showAlert: Bool = false
    
    var controller: ViewController
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.controller.showPage(page: Pages.overview) }) { Text("Back") }
                Spacer()
                Button(action: { self.controller.showPage(page: Pages.overview) }) { Text("Cancel") }
                Button(action: {
                    let ok = self.save()
                    self.showAlert = !ok
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
                EditPassExtrasView(extras: $extra)
                Button(action: {self.extra.append(PassExtra(key: "", value: "")) }) { Text("Add")}
            }
            Spacer()
        }.padding(15)
        
    }
    
    private func save() -> Bool {
        let dir = PassDirectory.getSavedPassFolder()
        if dir == nil || title == "" {
            return false
        }
        
        let filename = self.title.replacingOccurrences(of:" " , with: "_") + ".pgp"
        let path = dir!.appendingPathComponent(filename)
        var passItem = PassItem(title: self.title)
        passItem.username = self.login
        passItem.password = self.password
        passItem.extra = self.extra
        if !self.website.isEmpty {
            passItem.extra.append(PassExtra(key: "website", value: website))
        }
        
        return PassItemStorage().savePassItem(atURL: path, item: passItem)
    }
}



#if DEBUG
struct EditPassView_Previews: PreviewProvider {
   
    
    static var previews: some View {
        EditPassView(
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
