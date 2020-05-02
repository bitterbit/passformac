//
//  IntroView.swift
//  Passformac
//
//  Created by Gal on 04/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct IntroView : View {
    
    enum SetupViews: Int {
        case Default = 0
        case SetupFromDisk = 1
        case SetupFromScratch = 2
        case SetupFromRemote = 3
    }
    
    var controller: ViewController
    
    @State var view = SetupViews.Default
    @State var viewName : String?
    
    
    var body : some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            VStack {
                HStack {
                    if self.view != .Default {
                        Button(action: {
                            self.view = .Default
                            self.viewName = nil
                        }) { Image(nsImage: NSImage(named: NSImage.goBackTemplateName)!) }
                    } else {
                        Spacer()
                    }
                    
                    Text("Pass for Mac").font(.headline)
                    
                    if self.view != .Default {
                        Text("/ \(self.viewName!)").font(.subheadline)
                    }
                    Spacer()
                }
                
                Spacer()
                
                if self.view == .Default {
                    HStack {
                        self.btn("Create New", view: .SetupFromScratch)
                        self.btn("Import from Disk", view: .SetupFromDisk)
                        self.btn("Import from Git", view: .SetupFromRemote)
                    }
                } else if self.view == .SetupFromDisk {
                    SetupFromDiskView(controller: self.controller, onDone: self.onDone)
                } else if self.view == .SetupFromRemote {
                    SetupFromRemoteView(controller: self.controller, onDone: self.onDone)
                } else if self.view == .SetupFromScratch {
                    SetupFromScratchView(controller: self.controller, onDone: self.onDone)
                }
                Spacer()
            }
            .padding()
            .frame(
                width: deviceSize.size.width*0.7,
                height: deviceSize.size.height*0.7
            )
        }
    }
    
    private func btn(_ text: String, view: SetupViews) -> some View {
        Button(action: {
            self.view = view
            self.viewName = text
            
        }) { Text(text) }
    }
    
    private func onDone() {
        controller.showPage(page: .passphrase)
    }
}
