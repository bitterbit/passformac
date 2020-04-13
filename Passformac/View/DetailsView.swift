//
//  DetailsView.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct DetailsView: View {
    @State var details: PassItem
    
    var body: some View {
        inner
    }
    
    var inner: some View {
        VStack {
            Text(details.title).font(.headline).padding(20)
            if details.username != nil {
                KeyValueView(key: "Login", value: details.username!)
            }
            KeyValueView(key: "Pasword", value: details.password)
    
            ForEach (self.details.extra) { extra in
                KeyValueView(key: extra.key, value: extra.value)
            }
            Spacer()
        }.padding(100)
    }
}

struct KeyValueView: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text("\(key):").bold().font(.subheadline)
            Button(action: {
                self.copyToClipboard(value: self.value)
            }) {
                Text(value).font(.subheadline)
            }.buttonStyle(PlainButtonStyle())
        }.leftAligned()
    }
    
    private func copyToClipboard(value: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        clearClipboardIfStillThere(value: value)
    }
    
    private func clearClipboardIfStillThere(value: String){
        let deadline = Dispatch.DispatchTime.now() + 10 // +10 seconds
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            let pasteboard = NSPasteboard.general
            let v = pasteboard.string(forType: .string)
            if v == value {
                pasteboard.clearContents()
            }
        }
    }
}

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

extension View {
    func leftAligned() -> some View {
        return self.modifier(LeftAligned())
    }
}
