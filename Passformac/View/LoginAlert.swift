//
//  LoginAlert.swift
//  Passformac
//
//  Created by Gal on 02/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI
import AppKit

struct LoginAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    
    @State var login = Login()
    
    let presenting: Presenting
    let title: String
    let onDone: (Login) -> Void

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting.disabled(self.isShowing)
                VStack {
                    Text(self.title)
                    TextField("login" , text: self.$login.username)
                    SecureField("password", text: self.$login.password)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation { self.isShowing.toggle() }
                            self.onDone(self.login)
                        }) {
                            Text("OK")
                        }
                        Button(action: {
                            withAnimation { self.isShowing.toggle() }
                            self.login.username = ""
                            self.login.password = ""
                            self.onDone(self.login)
                        })
                        {
                            Text("Cancel")
                        }
                    }
                }
                .padding()
                .background(Color.gray) // TODO switch according to dark mode
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
                    title: String,
                    onDone: @escaping (Login) -> Void) -> some View {

        LoginAlert(isShowing: isShowing,
                   presenting: self,
                   title: title,
                   onDone: onDone)
    }

}
