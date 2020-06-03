//
//  VideoInterfaceView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct VideoInterfaceView: View {
    @ObservedObject var endpoint: Endpoint
    
    let imageProviderView = ImageProviderView()
    
    var body: some View {
        VStack {
            imageProviderView
            
            Toggle(isOn: $endpoint.isSending) {
                Text("Send to Server")
            }
                .disabled(!imageProviderView.isReady)
                .padding()
        }
    }
}

struct VideoInterfaceView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInterfaceView(endpoint: Endpoint(screenMode: Cartesian(width: 20, height: 20), address: URL(string: "")!))
    }
}
