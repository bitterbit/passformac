//
//  LabelSeperatorView.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct LabelSeperatorView : View {
    let label: String
    
    var body : some View {
        Text(label.uppercased()).font(.caption)
           .fontWeight(.bold)
           .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}
