//
//  VideoInterfaceView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

class VideoConnectionUIProxy: ObservableObject {
    var endpoint: VideoConnection
    var defaultFPS: Int = 30
    
    init(endpoint: VideoConnection) {
        self.endpoint = endpoint
        
        let roundedFPS = Int(endpoint.fps)
        fps = roundedFPS != defaultFPS ? String(roundedFPS) : ""
    }
    
    var fps: String {
        didSet {
            objectWillChange.send()

            var fps = Double(self.fps) ?? Double(defaultFPS)
            fps = fps < 100 && fps > 0 ? fps : Double(defaultFPS)
            endpoint.fps = fps
        }
    }
}

struct VideoConnectionView: View {
    @ObservedObject var assembly: ServerAssembly
    @ObservedObject var endpoint: VideoConnection
    @ObservedObject var endpointProxy: VideoConnectionUIProxy

    init(endpoint: VideoConnection) {
        self.assembly = endpoint.assembly.servers
        self.endpoint = endpoint
        self.endpointProxy = VideoConnectionUIProxy(endpoint: endpoint)
    }
            
    var body: some View {
        VStack {
            HStack {
                Text("FPS")
                    .fixedSize()
                    .frame(width: 50, alignment: .leading)
                
                TextField("30", text: $endpointProxy.fps)
                    .frame(minWidth: 100)
                
                Button(action: {
                    self.endpoint.isSending.toggle()
                }) {
                    Text(self.endpoint.isSending ? "Stop Streaming" : "Stream")
                        .frame(width: 200)
                }
                    .disabled(assembly.available.isEmpty)
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
