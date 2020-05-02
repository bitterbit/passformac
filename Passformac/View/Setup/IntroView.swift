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
    
    
    var body : some View {
        VStack{
            Text("Pass for Mac").font(.title)
            
            if view == .Default {
                HStack {
                    btn("Select from disk", view: .SetupFromDisk)
                    btn("Initialize new", view: .SetupFromScratch)
                    btn("Fetchup from remote git", view: .SetupFromRemote)
                }
            } else if view == .SetupFromDisk {
                SetupFromDiskView(controller: controller, onDone: self.onDone)
            } else if view == .SetupFromRemote {
                SetupFromRemoteView(controller: controller, onDone: self.onDone)
            } else if view == .SetupFromScratch {
                SetupFromScratchView()
            }
        }
    }
    
    private func btn(_ text: String, view: SetupViews) -> some View {
        Button(action: {
            self.view = view
        }) { Text(text) }
    }
    
    private func onDone() {
        controller.showPage(page: .passphrase)
        //controller.showPage(.)
    }
}
