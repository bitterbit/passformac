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
                    Text(self.title).font(.subheadline)
                    TextField("login" , text: self.$login.username)
                    SecureField("password", text: self.$login.password)
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
                .background(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 2).stroke(Color(NSColor.windowFrameColor), lineWidth: self.isShowing ? 0.5 : 0)
                    )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
                .padding(EdgeInsets(top: 0, leading: 100, bottom: 0, trailing: 100))
                
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

struct LoginAlert_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }.loginAlert(isShowing: .constant(true), title: "Authenticate", onDone: { _ in })
    }
}
