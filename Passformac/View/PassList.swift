//
//  PassListItem.swift
//  Passformac
//
//  Created by Gal on 29/03/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

//import Foundation
import SwiftUI


struct PassList: View {
    var controller: ViewController
    @Binding var passItems: [PassItem]
    @Binding var searchTerm: String
    
    var body: some View {
 
        List(self.passItems.filter{ passItem in
                self.searchTerm.isEmpty ? true : passItem.title.localizedStandardContains(self.searchTerm)
            }.sorted(by: {$0.title < $1.title })
        ) { passItem in Text(passItem.title).onTapGesture {
            self.controller.showDetailView(item: passItem)
        } }
    }
}
