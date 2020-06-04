//
//  ContentView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 01.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var selectedScreenMode = Server.Mode.cartesian

    @ObservedObject var server: Server
    let serverView: ServerView
    
    init() {
        let serverInfo = Server()
        self.server = serverInfo
        serverView = ServerView(server: serverInfo)
    }

    var body: some View {
        VStack() {
            serverView
            
            Spacer()
                .frame(height: 20)
                .fixedSize()
            
            if server.state == .connected {
                HStack {
                    Picker(selection: $selectedScreenMode, label: Text("Screen Mode")) {
                        ForEach(server.endpoints, id: \.self) { mode in
                            Text(mode.type.name).tag(mode)
                        }
                    }
                    
                    server.endpoint(mode: selectedScreenMode.type).map { endpoint in
                        Image(systemName: NSImage.quickLookTemplateName)
                            .overlay(TooltipView(endpoint.screenMode.description).withCursor())
                    }
                }

                // FIXME Duplicated because of "dependency"
                server.endpoint(mode: selectedScreenMode.type).map { endpoint in
                    VideoInterfaceView(endpoint: endpoint)
                }
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
