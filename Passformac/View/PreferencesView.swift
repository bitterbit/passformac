//
//  Preferences.swift
//  Passformac
//
//  Created by Gal on 15/05/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI
import Combine
import ObjectivePGP

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
    @State var gitRemoteAddress: String = ""
    @State var gitRemoteName: String = ""
    
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
                PrefTextField(label: "Remote Repository", value: $gitRemoteAddress).disabled(true)
                PrefTextField(label: "Remote", value: $gitRemoteName).disabled(true)
                PrefTextField(label: "Username", value: .constant("")).disabled(true)
                PrefTextField(label: "Password", value: .constant("")).disabled(true)
            }
            
            Group {
                PrefSeperator(label: "PGP")
                if keys.count <= 0 {
                    Text("No PGP Keys")
                }
                ForEach(keys) { item in
                    PrefPGPKeyRow(item: item)
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
        gitRemoteName = Config.shared.getGitRemoteName() ?? ""
        gitRemoteAddress = Config.shared.getGitRemoteAddress() ?? ""
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

struct PrefPGPKeyRow : View {
    var item : PrefKeyValue
    @State var showAlert = false
    
    var body : some View {
        HStack {
            Text(item.key)
            Text(item.value)
            
            // export
            Button(action: { self.export(keyId: self.item.value) }) {
                Image(nsImage: NSImage(named: NSImage.shareTemplateName)!)
            }.buttonStyle(PlainButtonStyle())
            
            // delete
            Button(action: { print ("remote \(self.item)")}) {
                Image(nsImage: NSImage(named: NSImage.stopProgressFreestandingTemplateName)!)
            }.buttonStyle(PlainButtonStyle()).disabled(true)
        }.alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text("Not logged in"))
        })
    }
    
    private func export(keyId: String) {
        if !PGPFileReader.shared.validatePassphrase() {
            showAlert = true
            return
        }
        
        guard let key = Config.shared.getPGPKey(withId: keyId) else {
            return
        }
        
        do {
            let pri = Armor.armored(try key.export(keyType: .secret), as: .secretKey)
            let pub = Armor.armored(try key.export(keyType: .public), as: .publicKey)
            
            Directory.selectDirectory({ dir in
                self.saveData(dir: dir, pri: pri, pub: pub)
            })
        } catch {
            print("error while exporting key \(keyId). error: \(error)")
            return
        }
    }
    
    private func saveData(dir: URL?, pri: String, pub: String) {
        guard let d = dir else {
            return
        }
        do {
            try pri.write(to: d.appendingPathComponent("passkey.private"), atomically: true, encoding: .utf8)
            try pub.write(to: d.appendingPathComponent("passkey.public"), atomically: true, encoding: .utf8)
        } catch {
            print("error while writing pgp keys to file. dir: \(d), error: \(error)")
        }
    }
}

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
            .padding(EdgeInsets(top: 5, leading: 0, bottom: -5, trailing: 0))
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
            gitRemoteName: "https://www.apple.com"
        )
    }
}
