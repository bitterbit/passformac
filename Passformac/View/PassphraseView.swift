//
//  PassphraseView.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct PassphraseView : View {
    var controller: ViewController
    @State private var passphrase: String = ""
    @State private var isWrongPassword: Bool = false
    
    var body : some View {
        VStack {
            Text("Welcome to Pass for Mac").font(.subheadline)
            
            SecureField("enter passphrase", text: $passphrase) {
                let isOk = PGPFileReader.shared.validatePassphrase(self.passphrase)
                if !isOk {
                    withAnimation { self.isWrongPassword = true }
                    print("wrong password")
                    return
                }
                
                self.controller.setPassphrase(passphrase: self.passphrase)
                self.isWrongPassword = false
                self.controller.showPage(page: Pages.overview)
            }
            if isWrongPassword {
                Text("wrong password").foregroundColor(.red).leftAligned()
            }
        }.padding(10)
    }
    

}
