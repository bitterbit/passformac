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
    
    var secure: Bool = false
    
    @State var hide: Bool = true
    
    var body: some View {
        Form {
            Text(label.uppercased()).font(.system(size: 10))
            HStack {
                if hide {
                    SecureField(placeHolder, text: self.$value)
                } else {
                    TextField(placeHolder, text: self.$value)
                }
                if secure {
                    Button(action: {
                        self.hide = !self.hide
                    }) { Image(nsImage: NSImage(named: NSImage.quickLookTemplateName)!) }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        .onAppear() {
            self.hide = self.secure
        }
        
    }
    
    
    
    
}
