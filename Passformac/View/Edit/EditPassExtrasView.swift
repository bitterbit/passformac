//
//  EditPassExtrasView.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct EditPassExtrasView : View {
    
    @Binding var extras : [PassExtra]
    
    var body : some View {
        Group {
            ForEach(extras) { extra in
                PassExtraRowItem(item: self.$extras[self.extras.firstIndex(of: extra)!]) {
                     self.extras.remove(at: self.extras.firstIndex(of: extra)!)
                }
            }
        }
    }
}


struct PassExtraRowItem : View {
    @Binding var item: PassExtra
    var onDelete: () -> Void
    
    var body : some View {
        HStack {
            LabelTextView(label: "key", value: $item.key).frame(minWidth: 0, maxWidth: 100)
            LabelTextView(label: "value", value: $item.value)
            Button(action: {
                self.onDelete()
            }) {
                Image(nsImage: NSImage(named: NSImage.stopProgressTemplateName)!)
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
