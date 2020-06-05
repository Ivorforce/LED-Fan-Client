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
    
    @State var isShowingDescription = false
    
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
                    
                    server.endpoint(mode: selectedScreenMode).map { endpoint in
                        Image(systemName: NSImage.quickLookTemplateName)
                            .onHover { isHovering in self.isShowingDescription = isHovering }
                            .popover(isPresented: $isShowingDescription, arrowEdge: .trailing) {
                                Text(endpoint.screenMode.description)
                            }
                    }
                }

                // FIXME Duplicated because of "dependency"
                server.endpoint(mode: selectedScreenMode).map { endpoint in
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
