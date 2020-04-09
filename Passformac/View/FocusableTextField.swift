//
//  FocusableTextView.swift
//  Passformac
//
//  Created by Gal on 05/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI
import AppKit

struct FocusableTextField: NSViewRepresentable {
    @Binding var text: String
    let hint: String
    let onSubmit: () -> Void

    func makeNSView(context: NSViewRepresentableContext<FocusableTextField>) -> NSTextField {
        let tf = NSSecureTextField()
        tf.placeholderString = hint
        tf.delegate = context.coordinator
        return tf
    }

    func updateNSView(_ nsView: NSTextField, context: NSViewRepresentableContext<FocusableTextField>) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> FocusableTextField.Coordinator {
        Coordinator(parent: self, onSubmit: self.onSubmit)
    }

    class Coordinator: NSObject, NSTextFieldDelegate  {
        let parent: FocusableTextField
        let onSubmit: () -> Void
        
        init(parent: FocusableTextField, onSubmit: @escaping ()->Void) {
            self.parent = parent
            self.onSubmit = onSubmit
        }
        

        func controlTextDidChange(_ obj: Notification) {
            let textField = obj.object as! NSTextField
            parent.text = textField.stringValue
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            self.onSubmit()
        }
    }
}
