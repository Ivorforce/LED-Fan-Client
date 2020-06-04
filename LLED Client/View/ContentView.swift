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

    @ObservedObject var serverInfo: ServerInfo
    let serverView: ServerView
    
    init() {
        let serverInfo = ServerInfo()
        self.serverInfo = serverInfo
        serverView = ServerView(serverInfo: serverInfo)
    }

    var body: some View {
        VStack() {
            serverView
            
            Spacer()
                .frame(height: 20)
                .fixedSize()
            
            if serverInfo.state == .connected {
                HStack {
                    Picker(selection: $selectedMode, label: Text("Screen Mode")) {
                        Text("Cartesian").tag(0)
                    }
                    
                    serverInfo.endpoint(mode: Self.selectableTypes[selectedMode]).map { endpoint in
                        Image(systemName: NSImage.quickLookTemplateName)
                            .overlay(TooltipView(endpoint.screenMode.description).withCursor())
                    }
                }

                // FIXME Duplicated because of "dependency"
                serverInfo.endpoint(mode: Self.selectableTypes[selectedMode]).map { endpoint in
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
