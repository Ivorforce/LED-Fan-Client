//
//  ImageProviderView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ImageProviderView: View {
    @State var selectedMode = 0
    
    var body: some View {
        Picker(selection: $selectedMode, label: Text("Capture Method")) {
            Text("Screen").tag(0)
        }
    }
    
    var isReady: Bool {
        return true
    }
}

struct ImageProviderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageProviderView()
    }
}
