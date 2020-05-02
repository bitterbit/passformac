//
//  LoginAlert.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI
import AppKit

struct Login {
    var username: String = ""
    var password: String = ""
    
    func isEmpty() -> Bool {
        if username.isEmpty || password.isEmpty {
            return true
        }
        return false
    }
}

struct LoginFormView : View {
    @Binding var login: Login
    
    let title: String
    let onDone: () -> Void

    var body: some View {
        VStack {
            Text(self.title)
            TextField("login" , text: self.$login.username)
            SecureField("password", text: self.$login.password)
            Divider()
            HStack {
                Button(action: {
                    self.onDone()
                }) {
                    Text("OK")
                }
                Button(action: {
                    self.login.username = ""
                    self.login.password = ""
                    self.onDone()
                })
                {
                    Text("Cancel")
                }
            }
        }
    }
}
