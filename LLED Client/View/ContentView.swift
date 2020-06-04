//
//  ContentView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 01.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static let selectableTypes: [ScreenMode.Type] = [
        Cartesian.self
    ]
    
    @State var selectedMode = 0

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
                    Picker(selection: $selectedMode, label: Text("Screen Mode")) {
                        ForEach(0 ..< Self.selectableTypes.count) { i in
                            Text(Self.selectableTypes[i].name).tag(i)
                        }
                    }
                    
                    server.endpoint(mode: Self.selectableTypes[selectedMode]).map { endpoint in
                        Image(systemName: NSImage.quickLookTemplateName)
                            .overlay(TooltipView(endpoint.screenMode.description).withCursor())
                    }
                }

                // FIXME Duplicated because of "dependency"
                server.endpoint(mode: Self.selectableTypes[selectedMode]).map { endpoint in
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
