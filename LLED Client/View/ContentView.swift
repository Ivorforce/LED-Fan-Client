//
//  ContentView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 01.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var server: Server
    let serverView: ServerView
    
    let videoEndpointView: VideoInterfaceView

    @State var isShowingDescription = false
    
    init() {
        let serverInfo = Server()
        self.server = serverInfo
        serverView = ServerView(server: serverInfo)
        videoEndpointView = VideoInterfaceView(endpoint: serverInfo.videoEndpoint)
    }

    var body: some View {
        VStack() {
            serverView
            
            Spacer()
                .frame(height: 20)
                .fixedSize()
            
            if server.state == .connected {
                HStack {
                    Picker(selection: $server.endpoint, label: Text("Screen Mode")) {
                        ForEach(server.endpoints, id: \.self) { mode in
                            Text(mode.type.name).tag(Optional.some(mode))
                        }
                    }
                    
                    Image(systemName: NSImage.quickLookTemplateName)
                        .onHover { isHovering in self.isShowingDescription = isHovering && self.server.videoEndpoint.screenMode != nil }
                        .popover(isPresented: $isShowingDescription, arrowEdge: .trailing) {
                            Text(self.server.videoEndpoint.screenMode?.description ?? "")
                                .padding()
                        }
                }

                videoEndpointView
            }
        }
            .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
