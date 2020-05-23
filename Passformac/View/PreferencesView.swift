//
//  Preferences.swift
//  Passformac
//
//  Created by Gal on 15/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

/**
    - Git
        - remote url
        - ? remote git username + password
    -   pgp keys
        - delete one
        - add one
    - current directory
    - reset all
        
 */

struct PreferencesView : View {
    @State var remoteGitUrl = Config.shared.getLocalDirectory()?.absoluteString ?? ""
    
    
    var body : some View {
        Form {
            Text("Preferences").font(.headline).leftAligned()
            
            PrefSeperator(label: "GENERAL")
            PrefTextField(label: "Pass Directory", value: .constant(""))
            
            PrefSeperator(label: "GIT")
            PrefTextField(label: "Remote Repository", value: .constant(""))
            PrefDirectoryField(label: "Local Directory", value: .constant(""))
            
            PrefSeperator(label: "PGP")
            HStack {
                Button(action: { print("..") } ) { Text("Add Private Key") }
                Button(action: { print("..") } ) { Text("Add Public Key") }
            }
            
            PrefSeperator(label: "Dangerous")
            
            Button(action: { print("..") } ) { Text("Reset") }
        }
        .padding(20)
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)

    }
}

struct PrefDirectoryField : View {
    var label: String
    var hint: String = ""
    @Binding var value : String
    
    var body : some View {
        VStack {
            PrefLabel(label: label)
            HStack {
                TextField(hint, text: $value)
                Button(action: { print("select directory") }) { Text("Select") }
            }
        }
    }
}


struct PrefTextField : View {
    var label: String
    var hint: String = ""
    @Binding var value : String
    
    var body : some View {
        VStack {
            PrefLabel(label: label)
            HStack {
                TextField(hint, text: $value)
            }
        }
    }
}

struct PrefLabel : View {
    var label : String
    
    var body : some View {
        Text(label).leftAligned().foregroundColor(.secondary).font(.caption)
            .padding(EdgeInsets(top: 5, leading: 0, bottom: -10, trailing: 0))
    }
}

struct PrefSeperator : View {
    var label : String
    
    var body : some View {
        HStack{
//            Spacer()
            Text(label).fontWeight(.bold).font(.caption)
//            Spacer()
        }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
