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
struct LoginAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @Binding var login: Login
    let presenting: Presenting
    let title: String
    let onDone: () -> Void

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(self.isShowing)
                VStack {
                    Text(self.title)
                    TextField("login" , text: self.$login.username)
                    SecureField("password", text: self.$login.password)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation { self.isShowing.toggle() }
                            self.onDone()
                        }) {
                            Text("OK")
                        }
                        Button(action: {
                            withAnimation { self.isShowing.toggle() }
                            self.login.username = ""
                            self.login.password = ""
                            self.onDone()
                        })
                        {
                            Text("Cancel")
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}


extension View {
    func loginAlert(isShowing: Binding<Bool>,
                    login: Binding<Login>,
                    title: String,
                    onDone: @escaping () -> Void) -> some View {

        LoginAlert(isShowing: isShowing,
                   login:login,
                   presenting: self,
                   title: title,
                   onDone: onDone)
    }

}
