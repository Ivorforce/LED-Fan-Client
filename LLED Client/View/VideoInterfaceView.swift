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
        
    var body: some View {
        VStack {
            imageProviderView
            
            HStack {
                TextField("30", text: Binding(
                    get: { self.endpoint.fps != 30 ? String(self.endpoint.fps) : "" },
                    set: { self.endpoint.fps = Double($0) ?? 30 }
                ))
                    .frame(minWidth: 100)
                
                Button(action: {
                    self.endpoint.isSending.toggle()
                }) {
                    Text(self.endpoint.isSending ? "Stop Streaming" : "Stream")
                        .frame(width: 200)
                }
                    .disabled(!imageProviderView.isReady)
                    .padding()
                
                ProgressIndicator(configuration: { view in
                    view.style = .spinning
                    view.controlSize = .small
                    view.startAnimation(self)
                    view.isHidden = !self.endpoint.isSending
                })
                    .frame(width: 20, height: 20)
            }
        }
    }
}

//struct VideoInterfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoInterfaceView(endpoint: VideoEndpoint(screenMode: Cartesian(net: 0, width: 20, height: 20), server: Server()))
//    }
//}
