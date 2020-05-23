//
//  Preferences.swift
//  Passformac
//
//  Created by Gal on 15/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI
import Combine

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

struct PrefKeyValue : Identifiable {
    var id: UUID = UUID()
    var key: String
    var value: String
}

struct PreferencesView : View {
    var changeNotifier = PassthroughSubject<Any?,Never>()
    
    @State var passDirectory: URL? = nil
    @State var gitRemote: String = ""
    
    @State var keys = [PrefKeyValue]()

    var body : some View {
        Form {
            Text("Preferences").font(.headline).leftAligned()
            
            // not allowed more than 10 elemnts under one view in swiftui, fix by grouping in groups
            // https://stackoverflow.com/questions/61178868/swiftui-random-extra-argument-in-call-error
            Group {
                PrefSeperator(label: "GENERAL")
                PrefDirectoryField(label: "Pass Directory", changeNotifier: changeNotifier, value: $passDirectory).disabled(true)
            }
            
            Group {
                PrefSeperator(label: "GIT")
                PrefTextField(label: "Remote Repository", value: $gitRemote).disabled(true)
                PrefTextField(label: "Username", value: .constant("")).disabled(true)
                PrefTextField(label: "Password", value: .constant("")).disabled(true)
            }
            
            Group {
                PrefSeperator(label: "PGP")
                if keys.count <= 0 {
                    Text("No PGP Keys")
                }
                ForEach(keys) { item in
                    HStack {
                        Button(action: { print ("remote \(item)")}) {
                            Image(nsImage: NSImage(named: NSImage.stopProgressFreestandingTemplateName)!)
                        }.buttonStyle(PlainButtonStyle()).disabled(true)
                        Text(item.key)
                        Text(item.value)
                    }
                }
                HStack {
                    Button(action: { print("..") } ) { Text("Add PGP Key") }.disabled(true)
                }
            }
            
            Group {
                PrefSeperator(label: "Dangerous")
                Button("Reset All", action: resetAll)
            }
        }.padding(20)
        .onAppear(perform: load)
    }
    
    private func load() {
        loadKeys()
        passDirectory = Config.shared.getLocalDirectory()
        gitRemote = Config.shared.getGitRemote() ?? ""
    }
    
    private func loadKeys() {
        self.keys = [PrefKeyValue]()
        
        let keys = Config.shared.getPGPKeys()
        for key in keys {
            var attr = [String]()
            if key.isPublic {
                attr.append("Public")
            }
            if key.isSecret {
                attr.append("Private")
            }
            self.keys.append(PrefKeyValue(key: attr.joined(separator: "+"), value: key.keyID.shortIdentifier))
        }
    }
    
    private func resetAll() {
        Config.shared.reset()
        load()
        changeNotifier.send(nil)
    }
}

import AppKit

struct PrefDirectoryField : View {
    var label: String
    var hint: String = ""
    var changeNotifier: PassthroughSubject<Any?, Never>
    @Binding var value : URL?
    @State var strValue: String = ""
    
    var body : some View {
        VStack {
            PrefLabel(label: label)
            HStack {
                TextField(hint, text: $strValue)
                Button(action: { print("select directory") }) { Text("Select") }
            }
        }.onAppear() {
            self.strValue = self.value?.absoluteString ?? ""
        }.onReceive(changeNotifier, perform: {_ in
            self.strValue = self.value?.absoluteString ?? ""
        })
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
            Text(label.uppercased()).fontWeight(.bold).font(.caption)
        }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        
    }
}


struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(
            passDirectory: URL(string: "https://www.apple.com"),
            gitRemote: "https://www.apple.com"
        )
    }
}
