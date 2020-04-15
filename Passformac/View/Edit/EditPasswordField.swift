//
//  EditPasswordField.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct EditPasswordView : View {
    @Binding var password: String
    @State var generatePassLength: Float = 0
    
    var passwordGenerator = MemorablePasswordGenerator()
    
    var body : some View {
        Group {
            LabelTextView(label: "Password", value: $password)
            HStack {
                Slider(value: $generatePassLength, in: 0 ... 10, step: 1) { startEvent in
                    if !startEvent {
                        self.generatePassword()
                    }
                }
                Button(action: generatePassword) {
                    Image(nsImage: NSImage(named: NSImage.refreshTemplateName)!)
                }
            }
        }
    }
    
    private func generatePassword() {
        passwordGenerator.numWords = Int(generatePassLength)
        password = passwordGenerator.generate()
    }
}
