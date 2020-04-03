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
    @Binding var passItems: [PassItem]
    @Binding var searchTerm: String
    
    var body: some View {
        VStack {
            List(self.passItems.filter{
                    self.searchTerm.isEmpty ? true : $0.title.localizedStandardContains(self.searchTerm)
                }.sorted(by: {$0.title < $1.title })
            ) {
                Text("\($0.title)")
                    .font(.subheadline)
            }
        }
    }
}
