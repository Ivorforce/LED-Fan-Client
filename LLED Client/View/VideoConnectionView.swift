//
//  VideoInterfaceView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 03.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct VideoConnectionView: View {
    @ObservedObject var assembly: ServerAssembly
    @ObservedObject var endpoint: VideoConnection

    init(endpoint: VideoConnection) {
        self.assembly = endpoint.assembly.servers
        self.endpoint = endpoint
    }
            
    var body: some View {
        VStack {
            HStack {
                Text("FPS")
                    .fixedSize()
                    .frame(width: 50, alignment: .leading)
                
                TextField("30", text: Binding(
                    get: { self.endpoint.fps != 30 ? String(self.endpoint.fps) : "" },
                    set: {
                        let fps = Double($0) ?? 30
                        self.endpoint.fps = fps < 100 && fps > 0 ? fps : 30
                    }
                ))
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
