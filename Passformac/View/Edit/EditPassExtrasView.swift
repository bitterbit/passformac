//
//  EditPassExtrasView.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI


struct EditPassExtrasView : View {
    @State var extra: [PassExtra] // use our own copy and publish updates with callback.
                                  // better for avoiding index-out-of-range errors

    // don't delete items, just mark hidden and don't expose them to the outer world
    @State var hiddenExtras: [UUID] = [UUID]()
    
    @State var aditionalExtras: [Binding<PassExtra>] = [Binding<PassExtra>]()
    
    // set this callback to get change updates
    // we pass a binding so the world gets updates of changes
    // and not only when a new item is created or deleted
    // only non-hidden items will be passed in the argument
    var onUpdate: ([Binding<PassExtra>]) -> Void = {_ in }
    
    var body : some View {
        Group {
            ForEach(self.extra) { e in
                if !self.isHidden(id: e.id) {
                    PassExtraRowItem(item: self.$extra[self.extra.firstIndex(of: e)!]) {
                        // on delete
                        self.markHiddne(id: e.id)
                        self.publishUpdate()
                    }
                }
            }
            
            Button(action: {
                self.extra.append(PassExtra(key: "", value: ""))
                self.publishUpdate()
            }) { Text("Add")}
        }
    }
    
    private func isHidden(id: UUID) -> Bool {
        return self.hiddenExtras.contains(id)
    }
    
    private func markHiddne(id: UUID) {
        self.hiddenExtras.append(id)
    }
    
    private func publishUpdate() {
        var extraBindings = [Binding<PassExtra>]()
        
        for i in 0..<extra.count {
            if !isHidden(id: extra[i].id) {
                let bind = Binding( get: {
                    return self.extra[i]
                }, set: { value in
                    self.extra[i] = value
                })
                extraBindings.append(bind)
            }
        }
        onUpdate(extraBindings)
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
