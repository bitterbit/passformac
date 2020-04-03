//
//  DetailsView.swift
//  Passformac
//
//  Created by Gal on 03/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import SwiftUI

struct DetailsView: View {
  let details: PassItem
  var body: some View {
    Text(details.title)
  }
}
