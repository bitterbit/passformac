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
    @Binding var passItems: [String]
    @Binding var searchTerm: String
    
    var body: some View {
        VStack {
            ForEach(self.passItems.filter{
                self.searchTerm.isEmpty ? true : $0.localizedStandardContains(self.searchTerm)
            }, id: \.self){
                PassItem(title: "\($0)")
            }
        }
    }
}


struct PassItem: View {
    @State var title: String
    
    var body: some View {
        VStack {
            Text(title)
        }
    }
}
