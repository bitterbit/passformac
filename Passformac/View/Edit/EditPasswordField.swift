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
    
    var body : some View {
        Group {
            LabelTextView(label: "Password", value: $password)
            Slider(value: $generatePassLength, in: 0 ... 100)
        }
    }
}
