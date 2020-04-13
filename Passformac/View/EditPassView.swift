//
//  EditPassView.swift
//  Passformac
//
//  Created by Gal on 12/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

// TODO
// 1. generate password
// 2. save to disk with encryption
// 3. implement go back / cancel


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
                LabelTextView(label: "Password", value: $password)
                
                Slider(value: .constant(0), in: 0 ... 100)
                
                Text("EXTRA").font(.caption)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                
                LabelTextView(label: "Website", placeHolder: "http://", value: $website)
            }
            Spacer()
        }.padding(15)
        
    }
    
    private func save() -> Bool {
        let dir = PassDirectory.getSavedPassFolder()
        if dir == nil || title == "" {
            return false
        }
        
        let path = dir!.appendingPathComponent(self.title)
        var passItem = PassItem(title: self.title)
        passItem.username = self.login
        passItem.password = self.password
        
        return PassItemStorage().savePassItem(atURL: path, item: passItem)
    }
}

struct LabelTextView : View {
    var label: String
    var placeHolder: String = ""
    @Binding var value: String
    
    
    var body: some View {
        Form {
            Text(label.uppercased()).font(.system(size: 10))
            TextField(placeHolder, text: self.$value)
        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
}

#if DEBUG
struct EditPassView_Previews: PreviewProvider {
   
    
    static var previews: some View {
        EditPassView(controller: getViewController())
    }
    
    static private func getViewController() -> ViewController {
        return  ViewController(
            currentPage: .constant(Pages.edit_pass),
            passItems: .constant([LazyPassItem]()),
            selectedPassItem: .constant(nil))
    }
}
#endif
