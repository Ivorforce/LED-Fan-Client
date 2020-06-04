//
//  VideoInterfaceView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct VideoInterfaceView: View {
    @ObservedObject var endpoint: VideoEndpoint
    
    let imageProviderView = ImageProviderView()
    
    @State var fpsString: String = ""
    
    var body: some View {
        VStack {
            imageProviderView
            
            HStack {
                TextField("30", text: Binding(
                    get: { String(self.endpoint.fps) },
                    set: { self.endpoint.fps = Double($0) ?? 30 }
                ))
                
                Toggle(isOn: $endpoint.isSending) {
                    Text("Send to Server")
                }
                    .disabled(!imageProviderView.isReady)
                    .padding()
            }
        }
    }
}

struct VideoInterfaceView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInterfaceView(endpoint: VideoEndpoint(screenMode: Cartesian(width: 20, height: 20), server: Server()))
    }
}
