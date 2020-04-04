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
        inner.onAppear() {
            print("on appear")
            if !self.details.isLoaded(){
                self.details.load()
            }
        }
    }
    
    var inner: some View {
        VStack {
            Text(details.title)
            Text(details.password)
        }
    }
    
}
