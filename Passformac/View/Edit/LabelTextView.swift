//
//  LabelTextView.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

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
