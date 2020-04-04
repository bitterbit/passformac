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
    
    var body : some View {
        VStack {
            Text("Welcome to Pass for Mac").font(.subheadline)
            SecureField("enter passphrase", text: $passphrase) {
                self.controller.setPassphrase(passphrase: self.passphrase)
                self.controller.showPage(page: Pages.overview)
            }
        }.padding(10)
    }
    

}
